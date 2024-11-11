## Project Structure

```
.
├── api/          # REST API implementation
├── contract/     # Smart contract code
└── README.md
```

## Getting Started

### 1. Start Local Blockchain

First, start Anvil (local blockchain) in a terminal:

```bash
anvil
```

This will start a local blockchain on `http://localhost:8545` with pre-funded accounts.

### 2. Deploy Smart Contract

In another terminal, deploy the smart contract:

```bash
cd contract
forge build
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" forge script script/DisperseCollect.s.sol --broadcast --rpc-url http://localhost:8545
```

### 3. Start API Server

In a new terminal, start the API server:

```bash
cd api
./run_api.sh
```

The API server will start on `http://localhost:3000`.

### 4. Run Tests

To run the integration tests, execute:

```bash
./run_tests.sh
```

Sample output:
```
$ ./run_tests.sh                                                                                                                                                                                       +
Checking services...

Dispersing ETH to two addresses...
{"tx_hash":"0xac4e609e0e70db76bfbec8db1128d8157cb7cf548eac289b41119ebb376bf8e5"}

Dispersing ETH to three addresses...
{"tx_hash":"0x62f8d2ea629a0ca15d92c93783889f781acf8a22ad89b91cf172686921c3ea35"}

Dispersing tokens to two addresses...
{"tx_hash":"0xe2b6873bcdb55a1d12c091d3a628fd43983c8d0ad782ba09b7785674da606e0a"}

Dispersing tokens to three addresses...
{"tx_hash":"0xef26b84ca714d6d8f881479321c1c0ac0c05cdf3d4ca6950635a8a057bf4e262"}

Dispersing eth by percentage...
{"tx_hash":"0xdf6e077a15a3051f336cf82c11524415b165bbd7fd6eb8bd06ee5e4d396406ac"}

Dispersing token by percentage...
{"tx_hash":"0x24af809969463a021bcd63ef8f35150ad79db922280fe92f9fe796a39da424ea"}

Collecting ETH from multiple addresses...
{"tx_hash":"0x8f486ccca39dc74066c63a5c8ef93cc34fd850bb9bf70294890784c0392d0de2"}

Approving token collection...
{"tx_hash":"0xc34c33bb638a0fe467f2cef86c8d9b895f2666f28b596d1f01902c6a0a9ede5c"}

Collecting tokens from multiple addresses...
{"tx_hash":"0xb040886fe7479e10a68f3b8c8e1a7bf35e238609c9d6de30d9c354eef422505e"}

Revoking token collection...
{"tx_hash":"0x3b01e3baadf9194a05003dac9ce3690d7b6ad1be7c3196f176f086abedf45ccc"}

Testing collection sequence...


Approving collection for multiple addresses...
{"tx_hash":"0x362175359be26046915bf05b747a92cb8e756e152432eee76adbab35f4ac0803"}

{"tx_hash":"0x02763a5dc39cb939e1ed639ae71cd08b83a51ecbc2bba18e08550fc8584f4286"}

{"tx_hash":"0x5dfd40cfea2ec721a796868ac13a4cddac725cbdbb0ebca5f1833a67d2e0fd26"}



Collecting from approved addresses...
{"tx_hash":"0x4280412c592e872d2fde1aa2bcd280c89eeabd08040edddb5cc4824ce1a3eedd"}

Revoking all approvals...
{"tx_hash":"0x71a04e3707a004ff9c9c14ea8f76f543c1afaa1ba50d1b672e768570747571d5"}

{"tx_hash":"0x9d057cc8cf216b1da057aa979864f9fd74f1a3577ca45a3cb83b4ab78c57ba0f"}

{"tx_hash":"0x1b202333fccf6e1fac66def672657f05a0cc1d8050d7479f468e98d7bfc0e922"}



Testing collect ETH with zero addresses (should fail)...
{"tx_hash":"0xf025a474075b4582dadeedbfa2ecdca64d034617bd108b6510ab0f6d0b602ac8"}

Testing collect without approval (should fail)...
{"tx_hash":"0x66831b1ec541be482f0b5a19c4b6b5b5e0d01078aaef0f9c3e6dbd67cf5fe086"}

All tests completed!
```
