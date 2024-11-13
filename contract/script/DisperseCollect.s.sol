// script/DisperseCollect.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {DisperseCollect} from "../src/DisperseCollect.sol";
import {TestToken} from "../src/TestToken.sol";

contract DisperseCollectScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DisperseCollect disperseCollect = new DisperseCollect();

        // Deploy TestToken
        TestToken token = new TestToken();

        // Transfer some tokens to test addresses for testing
        address addr1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        address addr2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        address addr3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
        
        token.transfer(addr1, 1000 * 10**18);
        token.transfer(addr2, 1000 * 10**18);
        token.transfer(addr3, 1000 * 10**18);

        vm.stopBroadcast();
    }
}
