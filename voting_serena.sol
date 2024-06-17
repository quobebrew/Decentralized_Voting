// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value -= 1;
    }
}

// Context.sol
contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract OpenZeppelinUpgradesOwnable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract VotingPlatform is OpenZeppelinUpgradesOwnable {
    using Counters for Counters.Counter;

    struct Voter {
        address addr;
        uint256 votingPower;
        bool isOwner;
    }

    struct Proposal {
        uint256 id;
        string description;
        uint256 deadline;
        mapping(address => int256) votes; // Votes can be positive or negative
        uint256 voteCount; // Total voting power used for this proposal
        int256 votesInFavor;
        int256 votesAgainst;
        uint256 votesAbstained;
        bool executed;
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => Proposal) public proposals;
    Counters.Counter private proposalIdCounter;

    uint256 public totalVotingPower;

    event ProposalCreated(uint256 proposalId, string description, uint256 deadline);
    event Voted(uint256 proposalId, address voter, int256 vote);
    event ProposalExecuted(uint256 proposalId);

    modifier onlyBeforeDeadline(uint256 proposalId) {
        require(block.timestamp < proposals[proposalId].deadline, "Voting deadline has passed");
        _;
    }

    modifier onlyValidProposal(uint256 proposalId) {
        require(proposals[proposalId].id != 0, "Invalid proposal ID");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].addr != address(0), "You are not a registered voter");
        _;
    }

    constructor() public OpenZeppelinUpgradesOwnable() {}

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

    function executeProposal(uint256 _proposalId) public onlyOwner onlyValidProposal(_proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(block.timestamp >= proposals[_proposalId].deadline, "Voting is still ongoing");

        // Implement logic for executing proposal, e.g., changing state, transferring tokens, etc.

        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }

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

    function getVotingPercentages(uint256 _proposalId) public view onlyValidProposal(_proposalId) returns (uint256, uint256, uint256) {
        Proposal storage proposal = proposals[_proposalId];
        uint256 totalVotes = proposal.voteCount;

        uint256 inFavorPercentage = totalVotes > 0 ? uint256(int256(proposal.votesInFavor) * 100 / int256(totalVotes)) : 0;
        uint256 againstPercentage = totalVotes > 0 ? uint256(int256(proposal.votesAgainst) * 100 / int256(totalVotes)) : 0;
        uint256 abstainedPercentage = totalVotes > 0 ? proposal.votesAbstained * 100 / totalVotes : 0;

        return (inFavorPercentage, againstPercentage, abstainedPercentage);
    }
}

