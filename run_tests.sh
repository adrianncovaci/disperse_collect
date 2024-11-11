#!/bin/bash

export CONTRACT_ADDRESS="0x5FbDB2315678afecb367f032d93F642f64180aa3"
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
export RPC_URL="http://localhost:8545"

API_URL="http://localhost:3000/api"
ADDR1="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
ADDR2="0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
ADDR3="0x90F79bf6EB2c4f870365E785982E1f101E93b906"
TOKEN_ADDR="0x5FbDB2315678afecb367f032d93F642f64180aa3"
COLLECTOR="0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"

# Function to check if the API is running
check_api() {
    curl --silent --connect-timeout 1 "http://localhost:3000/health" > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: API is not running on http://localhost:3000"
        exit 1
    fi
}

# Function to check if anvil is running
check_anvil() {
    curl --silent --connect-timeout 1 -X POST -H "Content-Type: application/json" \
         --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
         http://localhost:8545 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Anvil is not running on http://localhost:8545"
        exit 1
    fi
}

# Check services
echo "Checking services..."
check_api
check_anvil

# 1. Disperse ETH to two addresses
echo -e "\nDispersing ETH to two addresses..."
curl -X POST "${API_URL}/disperse/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"recipients\": [
      \"$ADDR1\",
      \"$ADDR2\"
    ],
    \"amounts\": [
      \"10000000000000\",
      \"20000000000000\"
    ]
  }"

# 2. Disperse ETH to three addresses
echo -e "\n\nDispersing ETH to three addresses..."
curl -X POST "${API_URL}/disperse/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"recipients\": [
      \"$ADDR1\",
      \"$ADDR2\",
      \"$ADDR3\"
    ],
    \"amounts\": [
      \"1000000000000000\",
      \"2000000000000000\",
      \"3000000000000000\"
    ]
  }"

# 3. Disperse tokens to two addresses
echo -e "\n\nDispersing tokens to two addresses..."
curl -X POST "${API_URL}/disperse/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN_ADDR\",
    \"recipients\": [
      \"$ADDR1\",
      \"$ADDR2\"
    ],
    \"amounts\": [
      \"100000000000000000\",
      \"200000000000000000\"
    ]
  }"

# 4. Disperse tokens to three addresses with smaller amounts
echo -e "\n\nDispersing tokens to three addresses..."
curl -X POST "${API_URL}/disperse/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN_ADDR\",
    \"recipients\": [
      \"$ADDR1\",
      \"$ADDR2\",
      \"$ADDR3\"
    ],
    \"amounts\": [
      \"50000000000\",
      \"10000000000\",
      \"15000000000\"
    ]
  }"

# 5. Disperse ETH by percentage
echo -e "\n\nDispersing eth by percentage..."
curl -X POST "${API_URL}/disperse/eth/percentage" \
-H "Content-Type: application/json" \
-d '{
    "recipients": [
        "0x1234567890123456789012345678901234567890",
        "0x2345678901234567890123456789012345678901",
        "0x3456789012345678901234567890123456789012"
    ],
    "percentages": ["3000", "3000", "4000"],
    "total_amount": "50000000000"
}'

# 6. Disperse token by percentage
echo -e "\n\nDispersing token by percentage..."
curl -X POST "${API_URL}/disperse/token/percentage" \
-H "Content-Type: application/json" \
-d '{
    "token": "0x4567890123456789012345678901234567890123",
    "recipients": [
        "0x1234567890123456789012345678901234567890",
        "0x2345678901234567890123456789012345678901",
        "0x3456789012345678901234567890123456789012"
    ],
    "percentages": ["3000", "3000", "4000"],
    "total_amount": "1000000000"
}'

# 7. Collect ETH from multiple addresses
echo -e "\n\nCollecting ETH from multiple addresses..."
curl -X POST "${API_URL}/collect/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": [
      \"${ADDR1}\",
      \"${ADDR2}\",
      \"${ADDR3}\"
    ],
    \"to\": \"${COLLECTOR}\",
    \"amount\": \"300000000000\"
  }"

# 8. Approve token collection
echo -e "\n\nApproving token collection..."
curl -X POST "${API_URL}/collect/approve" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN_ADDR}\",
    \"collector\": \"${COLLECTOR}\",
    \"percentage\": \"5000\"
  }"

# 9. Collect tokens from multiple addresses
echo -e "\n\nCollecting tokens from multiple addresses..."
curl -X POST "${API_URL}/collect/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN_ADDR}\",
    \"from\": [
      \"${ADDR1}\",
      \"${ADDR2}\",
      \"${ADDR3}\"
    ],
    \"to\": \"${COLLECTOR}\"
  }"

# 10. Revoke token collection
echo -e "\n\nRevoking token collection..."
curl -X POST "${API_URL}/collect/revoke" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN_ADDR}\",
    \"collector\": \"${COLLECTOR}\"
  }"

# Test multiple collection operations in sequence
echo -e "\n\nTesting collection sequence..."

# 11. Approve collection for multiple addresses
echo -e "\n\nApproving collection for multiple addresses..."
for ADDR in "${ADDR1}" "${ADDR2}" "${ADDR3}"; do
  curl -X POST "${API_URL}/collect/approve" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\": \"${TOKEN_ADDR}\",
      \"collector\": \"${COLLECTOR}\",
      \"percentage\": \"3000\"
    }"
  echo -e "\n"
done

# 12. Collect from approved addresses
echo -e "\n\nCollecting from approved addresses..."
curl -X POST "${API_URL}/collect/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN_ADDR}\",
    \"from\": [
      \"${ADDR1}\",
      \"${ADDR2}\",
      \"${ADDR3}\"
    ],
    \"to\": \"${COLLECTOR}\"
  }"

# 13. Revoke all approvals
echo -e "\n\nRevoking all approvals..."
for ADDR in "${ADDR1}" "${ADDR2}" "${ADDR3}"; do
  curl -X POST "${API_URL}/collect/revoke" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\": \"${TOKEN_ADDR}\",
      \"collector\": \"${COLLECTOR}\"
    }"
  echo -e "\n"
done

# 14. Edge case: Collect ETH with zero addresses
echo -e "\n\nTesting collect ETH with zero addresses (should fail)..."
curl -X POST "${API_URL}/collect/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": [],
    \"to\": \"${COLLECTOR}\",
    \"amount\": \"1000000000000000000\"
  }"

# 15. Edge case: Collect without approval
echo -e "\n\nTesting collect without approval (should fail)..."
curl -X POST "${API_URL}/collect/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN_ADDR}\",
    \"from\": [\"${ADDR1}\"],
    \"to\": \"${COLLECTOR}\"
  }"

echo -e "\n\nAll tests completed!"
