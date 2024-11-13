#!/bin/bash
export CONTRACT_ADDRESS="0x5FbDB2315678afecb367f032d93F642f64180aa3"
export TOKEN_ADDRESS="0x0165878A594ca255338adfa4d48449f69242Eb8F"
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
export RPC_URL="http://localhost:8545"

API_URL="http://localhost:3000/api"
ADDR1="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
ADDR2="0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
ADDR3="0x90F79bf6EB2c4f870365E785982E1f101E93b906"
COLLECTOR="0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"

check_api() {
    curl --silent --connect-timeout 1 "http://localhost:3000/health" > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: API is not running on http://localhost:3000"
        exit 1
    fi
}

check_anvil() {
    curl --silent --connect-timeout 1 -X POST -H "Content-Type: application/json" \
         --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
         http://localhost:8545 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Anvil is not running on http://localhost:8545"
        exit 1
    fi
}

echo "Checking services..."
check_api
check_anvil

# 1. Disperse ETH to two addresses...
echo -e "\nDispersing ETH to two addresses..."
curl -X POST "${API_URL}/disperse/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"recipients\": [\"$ADDR1\", \"$ADDR2\"],
    \"amounts\": [\"10000000000000\", \"20000000000000\"]
  }"

# 2. Disperse ETH to three addresses...
echo -e "\n\nDispersing ETH to three addresses..."
curl -X POST "${API_URL}/disperse/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"recipients\": [\"$ADDR1\", \"$ADDR2\", \"$ADDR3\"],
    \"amounts\": [\"1000000000000000\", \"2000000000000000\", \"3000000000000000\"]
  }"

# 3. Disperse tokens to two addresses...
echo -e "\n\nDispersing tokens to two addresses..."
curl -X POST "${API_URL}/disperse/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN_ADDRESS\",
    \"recipients\": [\"$ADDR1\", \"$ADDR2\"],
    \"amounts\": [\"100000000000000000\", \"200000000000000000\"]
  }"

# 4. Disperse tokens to three addresses...
echo -e "\n\nDispersing tokens to three addresses..."
curl -X POST "${API_URL}/disperse/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN_ADDRESS\",
    \"recipients\": [\"$ADDR1\", \"$ADDR2\", \"$ADDR3\"],
    \"amounts\": [\"50000000000\", \"10000000000\", \"15000000000\"]
  }"

# 5. Transfer ETH...
echo -e "\n\nTransferring ETH..."
curl -X POST "${API_URL}/collect/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": [\"$ADDR1\", \"$ADDR2\"],
    \"to\": \"$COLLECTOR\",
    \"amount\": \"300000000000\"
  }"

# 6. Transfer tokens...
echo -e "\n\nTransferring tokens..."
curl -X POST "${API_URL}/collect/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN_ADDRESS\",
    \"from\": [\"$ADDR1\", \"$ADDR2\"],
    \"to\": \"$COLLECTOR\",
    \"amount\": \"100000000000\"
  }"

# 7. Test edge cases...
echo -e "\n\nTesting transfer ETH with zero amount (should fail)..."
curl -X POST "${API_URL}/collect/eth" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": [\"$ADDR1\"],
    \"to\": \"$COLLECTOR\",
    \"amount\": \"0\"
  }"

echo -e "\n\nTesting token transfer with insufficient balance (should fail)..."
curl -X POST "${API_URL}/collect/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN_ADDRESS\",
    \"from\": [\"$ADDR1\"],
    \"to\": \"$COLLECTOR\",
    \"amount\": \"100000000000000000000000000000000\"
  }"

echo -e "\n\nAll tests completed!"
