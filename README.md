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
