// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

// Library to handle counters
library Counters {
    struct Counter {
        uint256 _value; // Default value is 0
    }

    // Function to get the current value of the counter
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    // Function to increment the counter
    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    // Function to decrement the counter
    function decrement(Counter storage counter) internal {
        counter._value -= 1;
    }
}

// Context contract to provide information about the current execution context
contract Context {
    constructor () internal { }

    // Function to get the address of the sender of the transaction
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    // Function to get the data of the transaction
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// Ownable contract to handle ownership of the contract
contract OpenZeppelinUpgradesOwnable is Context {
    address private _owner;

    // Event to emit when ownership is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor to set the deployer as the initial owner
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    // Function to get the current owner
    function owner() public view returns (address) {
        return _owner;
    }

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    // Function to check if the caller is the owner
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    // Function for the owner to renounce ownership
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Function to transfer ownership to a new owner
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    // Internal function to transfer ownership to a new owner
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Main contract for the voting platform
contract VotingPlatform is OpenZeppelinUpgradesOwnable {
    using Counters for Counters.Counter;

    // Struct to represent a voter
    struct Voter {
        address addr; // Voter's address
        uint256 votingPower; // Voter's voting power
        bool isOwner; // Flag to indicate if the voter is an owner
    }

    // Struct to represent a proposal
    struct Proposal {
        uint256 id; // Proposal ID
        string description; // Description of the proposal
        uint256 deadline; // Deadline for voting on the proposal
        mapping(address => int256) votes; // Mapping of voters and their vote status
        uint256 voteCount; // Total voting power used for this proposal
        int256 votesInFavor; // Votes in favor of the proposal
        int256 votesAgainst; // Votes against the proposal
        uint256 votesAbstained; // Votes abstained from the proposal
        bool executed; // Flag indicating if the proposal has been executed
    }

    // Mapping to store voters with their addresses
    mapping(address => Voter) public voters;
    // Mapping to store proposals with their IDs
    mapping(uint256 => Proposal) public proposals;
    // Counter to generate unique proposal IDs
    Counters.Counter private proposalIdCounter;

    uint256 public totalVotingPower; // Total voting power

    // Events
    event ProposalCreated(uint256 proposalId, string description, uint256 deadline);
    event Voted(uint256 proposalId, address voter, int256 vote);
    event ProposalExecuted(uint256 proposalId);

    // Modifier to check if the voting deadline for a proposal has not passed
    modifier onlyBeforeDeadline(uint256 proposalId) {
        require(block.timestamp < proposals[proposalId].deadline, "Voting deadline has passed");
        _;
    }

    // Modifier to check if a proposal with a given ID exists
    modifier onlyValidProposal(uint256 proposalId) {
        require(proposals[proposalId].id != 0, "Invalid proposal ID");
        _;
    }

    // Modifier to check if the caller is a registered voter
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].addr != address(0), "You are not a registered voter");
        _;
    }

    // Constructor to initialize the contract with the contract creator as the owner
    constructor() public OpenZeppelinUpgradesOwnable() {}

    // Function to register a voter
    function registerVoter(address _voter, uint256 _votingPower, bool _isOwner) external onlyOwner {
        require(voters[_voter].addr == address(0), "Voter already registered");
        require(totalVotingPower + _votingPower <= 100, "Total voting power exceeds 100");
        
        voters[_voter] = Voter({
            addr: _voter,
            votingPower: _votingPower,
            isOwner: _isOwner
        });
        
        totalVotingPower += _votingPower;
    }

    // Function to create a new proposal
    function createProposal(string memory _description, uint256 _duration) public onlyRegisteredVoter {
        proposalIdCounter.increment();
        uint256 proposalId = proposalIdCounter.current();

        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + _duration;
        newProposal.voteCount = 0;
        newProposal.votesInFavor = 0;
        newProposal.votesAgainst = 0;
        newProposal.votesAbstained = 0;
        newProposal.executed = false;

        emit ProposalCreated(proposalId, _description, newProposal.deadline);
    }

    // Function for registered voters to vote on a proposal
    function vote(uint256 _proposalId, int256 _vote) public onlyBeforeDeadline(_proposalId) onlyRegisteredVoter onlyValidProposal(_proposalId) {
        require(proposals[_proposalId].votes[msg.sender] == 0, "You have already voted");
        require(_vote >= -1 && _vote <= 1, "Invalid vote: must be -1, 0, or 1");
        
        proposals[_proposalId].votes[msg.sender] = _vote;
        proposals[_proposalId].voteCount += uint256(voters[msg.sender].votingPower);
        
        if (_vote > 0) {
            proposals[_proposalId].votesInFavor += int256(voters[msg.sender].votingPower);
        } else if (_vote < 0) {
            proposals[_proposalId].votesAgainst += int256(voters[msg.sender].votingPower);
        } else {
            proposals[_proposalId].votesAbstained += voters[msg.sender].votingPower;
        }
        
        emit Voted(_proposalId, msg.sender, _vote);
    }

    // Function to execute a proposal after the voting deadline
    function executeProposal(uint256 _proposalId) public onlyOwner onlyValidProposal(_proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(block.timestamp >= proposals[_proposalId].deadline, "Voting is still ongoing");

        // Implement logic for executing proposal, e.g., changing state, transferring tokens, etc.

        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }

    // Function to get a proposal's details
    function getProposal(uint256 _proposalId) public view onlyValidProposal(_proposalId) returns (uint256, string memory, uint256, uint256, int256, int256, uint256, bool) {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.deadline,
            proposal.voteCount,
            proposal.votesInFavor,
            proposal.votesAgainst,
            proposal.votesAbstained,
            proposal.executed
        );
    }

    // Function to get voting percentages for a proposal
    function getVotingPercentages(uint256 _proposalId) public view onlyValidProposal(_proposalId) returns (uint256, uint256, uint256) {
        Proposal storage proposal = proposals[_proposalId];
        uint256 totalVotes = proposal.voteCount;

        uint256 inFavorPercentage = totalVotes > 0 ? uint256(int256(proposal.votesInFavor) * 100 / int256(totalVotes)) : 0;
        uint256 againstPercentage = totalVotes > 0 ? uint256(int256(proposal.votesAgainst) * 100 / int256(totalVotes)) : 0;
        uint256 abstainedPercentage = totalVotes > 0 ? proposal.votesAbstained * 100 / totalVotes : 0;

        return (inFavorPercentage, againstPercentage, abstainedPercentage);
    }
}
