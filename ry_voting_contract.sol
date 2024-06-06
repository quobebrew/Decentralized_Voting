/* 
Decentralized Voting Platform
*/

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Votes.sol";


// This contract will implement a decentralized voting platform for owners of equity in a company/contract to vote on proposals and changes to the company/contract.
// The contract will be initialized with a list of owners of equity in the company/contract.
// The contract will have a list of proposals that owners can vote on. New proposals may be added by any owner.
// The contract will have a list of votes for each proposal, with each owner being able to vote once on each proposal.
// Each owners vote will weighted by the amount of tokens they own in their wallets.
// The contract will have a function to tally the votes for each proposal and determine the outcome of the vote.

// The contract will be implemented using the OpenZeppelin ERC20Votes contract to manage the equity ownership and voting rights of the owners.

// The contract will have the following functions:
// 1. A function to add a new proposal to the list of proposals.
// 2. A function to allow an owner to vote on a proposal.
// 3. A function to tally the votes for a proposal and determine the outcome of the vote.
// 4. A list of owners and their equity ownership in the company/contract.
// 5. A list of proposals and their vote counts, and the duration of the vote.
// 6. A list of votes for each proposal, with the owner's address and the number of votes they cast.

contract VotingContract is ERC20Votes {
    
    // Define a struct to represent a proposal
    struct Proposal {
        string description;
        uint voteCount;
        uint duration;
        uint startTime;
        mapping(address => bool) voted;
    }

    // Define a struct to represent an owner, store his/her name, equity ownership and voting rights
    struct Owner {
        string name;
        uint equityOwnership;
        uint votingRights;
    }
    // Define a mapping to store the proposals
    mapping(uint => Proposal) public proposals;
    
    // Define a counter for the proposals
    uint public proposalCount;
    
    // Define a mapping to store the votes for each proposal
    mapping(uint => mapping(address => uint)) public votes;
    
    // Define a mapping to store the owners and their equity ownership
    mapping(address => uint) public equityOwnership;
    
    // Define a modifier to check if the caller is an owner
    modifier onlyOwner() {
        require(equityOwnership[msg.sender] > 0, "Caller is not an owner");
        _;
    }
    
    // Define a function to add a new proposal
    function addProposal(string memory _description, uint _duration) public onlyOwner {
        proposals[proposalCount] = Proposal(_description, 0, _duration, block.timestamp);
        proposalCount++;
    }
    
    // Define a function to allow an owner to vote on a proposal
    function vote(uint _proposalId, uint _votes) public onlyOwner {
        require(proposals[_proposalId].startTime + proposals[_proposalId].duration > block.timestamp, "Voting period has ended");
        require(!proposals[_proposalId].voted[msg.sender], "Owner has already voted");
        proposals[_proposalId].voteCount += _votes;
        votes[_proposalId][msg.sender] = _votes;
        proposals[_proposalId].voted[msg.sender] = true;
    }
    
    // Define a function to tally the votes for a proposal and determine the outcome of the vote
    function tallyVotes(uint _proposalId) public view returns (uint, uint) {
        return (proposals[_proposalId].voteCount, proposals[_proposalId].startTime + proposals[_proposalId].duration);
    }
    
    // Define a function to add an owner and their equity ownership
    function addOwner(address _owner, uint _equityOwnership) public onlyOwner {
        equityOwnership[_owner] = _equityOwnership;
    }
    
    // Define a function to remove an owner
    function removeOwner(address _owner) public onlyOwner {
        equityOwnership[_owner] = 0;
    }

    // Define a function to return the current proposal and the votes
    function currentProposal() public view returns (string memory, uint, uint) {
        return (proposals[proposalCount - 1].description, proposals[proposalCount - 1].voteCount, proposals[proposalCount - 1].duration);
    }
