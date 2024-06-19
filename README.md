The Code is in the Iteration_3_deligation folder
# Decentralized Voting Platform

## Project Overview

**Objective:** Build a decentralized voting platform where users (stakeholders) can propose topics and vote on them. Each vote is recorded on the Ethereum blockchain for transparency and security.
This project is a decentralized application (dApp) that enables users to create and vote on proposals using Ethereum smart contracts with a user-friendly interface built with Streamlit.

## Key Features

1. **User Authentication:** Secure methods for voter registration and authentication.
2. **Proposal Creation:** Mechanism for users to create and submit proposals.
3. **Vote Casting:** Mechanism for users to cast their votes securely.
4. **Vote Counting:** Automated and transparent vote counting.
5. **Result Verification:** Publicly verifiable voting results.
6. **Anonymity:** Ensuring voter privacy while maintaining vote integrity.
7. **Auditability:** Full audit trail for the entire voting process.

## Technical Stack

- **Blockchain Platform:** Ethereum (or any compatible blockchain with smart contract capabilities).
- **Smart Contract Language:** Solidity.
- **Front-End:** Streamlit, Web3.py for blockchain interaction.
- **Authentication:** Integration with identity verification services (Good to have)eg Civic

## Smart Contract Outline

The smart contract handles voter registration, vote casting, and vote counting. Developed using Solidity

## Front-End Integration with Streamlit

1. **Voter Registration and Authentication:**

- Implement a secure registration system where eligible voters can register and be authorized.
- Use identity verification services to authenticate voters (good to have)

2. **Proposal Creation Interface:**

- Develop a user-friendly interface with Streamlit where users can create and submit proposals.
- Integrate with Web3.py to interact with the smart contract and record proposals on the blockchain.

3. **Vote Casting Interface:**

- Develop a user-friendly interface with Streamlit where voters can log in, view proposals, and cast their votes.
- Integrate with Web3.py to interact with the smart contract and record votes on the blockchain.

4. **Vote Counting and Results Display:**

- Automatically update and display the vote counts in real-time.
- Provide a transparent results page where voters can verify the integrity of the election.

## Edge Cases
1. **Voting by Proxy**
- Description: Allows a voter to delegate their voting power to another individual (proxy).
- Implementation: Modify the smart contract to include proxy functionality.

2. **Delegation**
- Description: Voters can delegate their voting rights to another address for a specific voting event.
- Implementation: Add delegation functionality to the smart contract.

3. **Token-Based Voting**
- Description: Votes are weighted based on the number of tokens or stocks held by a voter.
- Implementation: Integrate ERC20/ERC721 token standards for weighted voting.

### Execution Flow of Decentralized Voting Process

#### 1. Contract Deployment
- **Action**: Deploy the `VotingPlatform` contract to the blockchain.
- **Responsible**: Contract owner or deployer.
- **Outcome**: The smart contract is now available on the blockchain, with the deployer as the owner.

#### 2. Voter Registration
- **Action**: Register voters who will participate in the voting process.
- **Function**: `registerVoter(address _voter, uint256 _votingPower, bool _isOwner)`
- **Responsible**: Contract owner.
- **Steps**:
  1. The contract owner calls `registerVoter` with the voter's address, their voting power, and whether they are an owner.
  2. The function checks if the voter is already registered.
  3. If not, it adds the voter to the `voters` mapping.
- **Outcome**: Voters are registered and assigned voting power.

#### 3. Proposal Creation
- **Action**: Create a new proposal for voting.
- **Function**: `createProposal(string memory _description, uint256 _duration)`
- **Responsible**: Registered voters.
- **Steps**:
  1. A registered voter calls `createProposal` with the proposal description and duration for voting.
  2. The function increments the `proposalIdCounter`.
  3. A new `Proposal` struct is created and stored in the `proposals` mapping with the new ID.
  4. The function emits a `ProposalCreated` event.
- **Outcome**: A new proposal is created and ready for voting.

#### 4. Voting on a Proposal
- **Action**: Vote on an existing proposal.
- **Function**: `vote(uint256 _proposalId)`
- **Responsible**: Registered voters.
- **Steps**:
  1. A registered voter calls `vote` with the ID of the proposal they want to vote on.
  2. The function checks if the voting deadline has not passed.
  3. It ensures the proposal exists and that the voter has not already voted.
  4. The voter's vote is recorded, and the `voteCount` for the proposal is updated.
  5. The function emits a `Voted` event.
- **Outcome**: Votes are recorded for the proposal until the voting deadline.

#### 5. Executing a Proposal
- **Action**: Execute the proposal after the voting period ends.
- **Function**: `executeProposal(uint256 _proposalId)`
- **Responsible**: Contract owner.
- **Steps**:
  1. The contract owner calls `executeProposal` with the ID of the proposal to be executed.
  2. The function checks if the proposal has not been executed and that the voting period has ended.
  3. The logic for executing the proposal (such as transferring tokens, changing state, etc.) is implemented.
  4. The proposal is marked as executed.
  5. The function emits a `ProposalExecuted` event.
- **Outcome**: The proposal's actions are carried out based on the vote outcome.

### Summary of Execution Flow
1. **Deploy Contract**: Owner deploys the smart contract.
2. **Register Voters**: Owner registers voters with their voting power.
3. **Create Proposals**: Registered voters create proposals.
4. **Vote on Proposals**: Voters cast their votes on proposals.
5. **Execute Proposals**: Owner executes proposals after the voting period ends, finalizing the process.

### Contributors
- Alfred Brew – Team Lead
- Vishnu Ganapathiappan Vardhan – Lead Developer
- Chris Cronin – Product Research 
- Ravi Yeleswarapu – Sales & Marketing
- Serena Shkabari – Member


