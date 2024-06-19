import os
import json
from web3 import Web3
import streamlit as st
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv('KEY.env')

# Load environment variables
WEB3_PROVIDER_URI = os.getenv('WEB3_PROVIDER_URI')
CONTRACT_ADDRESS = os.getenv('CONTRACT_ADDRESS')

# Check if environment variables are loaded correctly
if not WEB3_PROVIDER_URI:
    st.error("WEB3_PROVIDER_URI is not set. Please check your .env file.")
if not CONTRACT_ADDRESS:
    st.error("CONTRACT_ADDRESS is not set. Please check your .env file.")

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
voting_power = st.number_input("Voting Power", min_value=0)  # Allow 0 as input for delegations
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
        st.error("Unable to register voter. Please check the input data and try again.")

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
        st.error("Unable to create proposal. Please check the input data and try again.")

# Vote on a proposal
st.header("Vote on a Proposal")
proposal_id_vote = st.number_input("Proposal ID to Vote On", min_value=1)
vote_value = st.radio("Vote", (-1, 0, 1), key="vote_radio")

if st.button("Vote"):
    try:
        tx = contract.functions.vote(proposal_id_vote, vote_value).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Please ensure you are voting before the deadline or haven't already voted.")

# Delegate a vote
st.header("Delegate a Vote")
proposal_id_delegate = st.number_input("Proposal ID to Delegate", min_value=1, key="delegate_proposal_id")
delegate_to_address = st.text_input("Delegate To Address")

if st.button("Delegate Vote"):
    try:
        tx = contract.functions.delegateVote(proposal_id_delegate, delegate_to_address).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to delegate vote. Please check the input data and try again.")

# Vote by delegate
st.header("Vote by Delegate")
proposal_id_delegate_vote = st.number_input("Proposal ID to Vote On behalf of a Delegate", min_value=1, key="delegate_vote_proposal_id")
delegate_voter_address = st.text_input("Delegated Voter Address")
vote_value_delegate = st.radio("Vote", (-1, 0, 1), key="delegate_vote_radio")

if st.button("Vote by Delegate"):
    try:
        tx = contract.functions.voteByDelegate(proposal_id_delegate_vote, int(delegate_voter_address, 0), vote_value_delegate).build_transaction({
            'from': selected_account,
            'nonce': w3.eth.get_transaction_count(selected_account),
            'gas': 2000000,
            'gasPrice': w3.to_wei('20', 'gwei')
        })
        tx_receipt = w3.eth.send_transaction(tx)
        st.write(f"Transaction hash: {tx_receipt.hex()}")
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to vote by delegate. Please check the input data and try again.")

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
        st.error("Unable to execute proposal. Make sure voting is closed and the proposal has not already been executed.")

# Display proposals
st.header("View Proposals")
proposal_id_view = st.number_input("Proposal ID to View", min_value=1, key="view_proposal_id")

if st.button("View Proposal"):
    try:
        proposal = contract.functions.getProposal(proposal_id_view).call()
        in_favor_percentage, against_percentage, abstained_percentage = contract.functions.getVotingPercentages(proposal_id_view).call()
        st.write({
            "ID": proposal[0],
            "Description": proposal[1],
            "Deadline": proposal[2],
            "Vote Count": proposal[3],
            "Votes In Favor": proposal[4],
            "Votes Against": proposal[5],
            "Votes Abstained": proposal[6],
            "Executed": proposal[7],
            "In Favor (%)": in_favor_percentage,
            "Against (%)": against_percentage,
            "Abstained (%)": abstained_percentage
        })
    except ValueError as ve:
        st.error(f"Error: {ve}")
        st.error("Unable to fetch proposal details. Please check the proposal ID and try again.")

