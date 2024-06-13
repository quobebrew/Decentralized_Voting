import os
import json
from web3 import Web3
import streamlit as st
from dotenv import load_dotenv

load_dotenv('KEY.env')

# Load environment variables
WEB3_PROVIDER_URI = os.getenv('WEB3_PROVIDER_URI')
CONTRACT_ADDRESS = os.getenv('CONTRACT_ADDRESS')

# Connect to Ethereum node
w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER_URI))

# Load the contract ABI
with open('VotingPlatform.json', 'r') as file:
    contract_abi = json.load(file)

# Connect to the contract
contract = w3.eth.contract(address=CONTRACT_ADDRESS, abi=contract_abi)

# Get the list of accounts from Ganache
accounts = w3.eth.accounts
st.title("Decentralized Voting Platform")

# Select account from dropdown
selected_account = st.selectbox("Select Account", accounts)
w3.eth.default_account = selected_account

# Register a voter
st.header("Register a Voter")
voter_address = st.text_input("Voter Address")
voting_power = st.number_input("Voting Power", min_value=1)
is_owner = st.checkbox("Is Owner")

if st.button("Register Voter"):
    try:
        tx = contract.functions.registerVoter(voter_address, voting_power, is_owner).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to register voter. Please check the input data and try again")

# Create a proposal
st.header("Create a Proposal")
description = st.text_area("Proposal Description")
duration = st.number_input("Duration (in seconds)", min_value=1)

if st.button("Create Proposal"):
    try:
        tx = contract.functions.createProposal(description, duration).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to create proposal. Please check the input data and try again")

# Vote on a proposal
st.header("Vote on a Proposal")
proposal_id_vote = st.number_input("Proposal ID to Vote On", min_value=1)

if st.button("Vote"):
    try:
        tx = contract.functions.vote(proposal_id_vote).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Please ensure you are voting before the deadline or haven't already voted")

# Execute a proposal
st.header("Execute a Proposal")
proposal_id_execute = st.number_input("Proposal ID to Execute", min_value=1)

if st.button("Execute Proposal"):
    try:
        tx = contract.functions.executeProposal(proposal_id_execute).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to execute proposal. Make sure voting is closed and the proposal has not already been executed")

# Display proposals
st.header("View Proposals")
proposal_id_view = st.number_input("Proposal ID to View", min_value=1)

if st.button("View Proposal"):
    try:
        proposal = contract.functions.getProposal(proposal_id_view).call()
        st.write(proposal)
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to fetch proposal details. Please check the proposal ID and try again")
