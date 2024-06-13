// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VotingPlatform is Ownable {
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
        mapping(address => bool) votes; // Mapping of voters and their vote status
        uint256 voteCount; // Total count of votes received
        bool executed; // Flag indicating if the proposal has been executed
    }

    // Mapping to store voters with their addresses
    mapping(address => Voter) public voters;
    // Mapping to store proposals with their IDs
    mapping(uint256 => Proposal) public proposals;
    // Counter to generate unique proposal IDs
    Counters.Counter private proposalIdCounter;

    // Event emitted when a new proposal is created
    event ProposalCreated(uint256 proposalId, string description, uint256 deadline);
    // Event emitted when a user casts a vote
    event Voted(uint256 proposalId, address voter);
    // Event emitted when a proposal is executed
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
    constructor() Ownable(msg.sender) {}

    // Function to register a voter
    function registerVoter(address _voter, uint256 _votingPower, bool _isOwner) external onlyOwner {
        require(voters[_voter].addr == address(0), "Voter already registered");
        voters[_voter] = Voter({
            addr: _voter,
            votingPower: _votingPower,
            isOwner: _isOwner
        });
    }

    // Function to create a new proposal
    function createProposal(string memory _description, uint256 _duration) external onlyRegisteredVoter {
        proposalIdCounter.increment();
        uint256 proposalId = proposalIdCounter.current();

        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + _duration;
        newProposal.voteCount = 0;
        newProposal.executed = false;

        emit ProposalCreated(proposalId, _description, block.timestamp + _duration);
    }

    // Function for registered voters to vote on a proposal
    function vote(uint256 _proposalId) external onlyBeforeDeadline(_proposalId) onlyRegisteredVoter onlyValidProposal(_proposalId) {
        require(!proposals[_proposalId].votes[msg.sender], "You have already voted");
        proposals[_proposalId].votes[msg.sender] = true;
        proposals[_proposalId].voteCount += voters[msg.sender].votingPower;
        emit Voted(_proposalId, msg.sender);
    }

    // Function to execute a proposal after the voting deadline
    function executeProposal(uint256 _proposalId) external onlyOwner onlyValidProposal(_proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(block.timestamp >= proposals[_proposalId].deadline, "Voting is still ongoing");
        
        // Implement logic for executing proposal, e.g., changing state, transferring tokens, etc.

        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }
}
