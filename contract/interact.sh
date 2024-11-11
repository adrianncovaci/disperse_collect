#!/bin/bash
CONTRACT_ADDRESS="0x5FbDB2315678afecb367f032d93F642f64180aa3"
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
RPC_URL="http://localhost:8545"

ADDRESS1="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
ADDRESS2="0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"

# Function to check ETH balance
check_balance() {
    echo "Checking balance for $1..."
    cast balance $1 --rpc-url $RPC_URL
}

# Function to disperse ETH
disperse_eth() {
    echo "Dispersing ETH..."
    cast send $CONTRACT_ADDRESS \
    "disperseEth(address[],uint256[])" \
    "[$ADDRESS1,$ADDRESS2]" \
    "[1000000000000000000,2000000000000000000]" \
    --value 3000000000000000000 \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY
}

# Function to disperse by percentage
disperse_by_percentage() {
    echo "Dispersing ETH by percentage..."
    cast send $CONTRACT_ADDRESS \
    "disperseEthByPercentage(address[],uint256[])" \
    "[$ADDRESS1,$ADDRESS2]" \
    "[3000,7000]" \
    --value 1000000000000000000 \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY
}

# Show menu
echo "What would you like to do?"
echo "1) Check balances"
echo "2) Disperse ETH (fixed amounts)"
echo "3) Disperse ETH (by percentage)"
echo "4) Exit"

read -p "Enter your choice: " choice

case $choice in
    1)
        check_balance $ADDRESS1
        check_balance $ADDRESS2
        ;;
    2)
        disperse_eth
        ;;
    3)
        disperse_by_percentage
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
