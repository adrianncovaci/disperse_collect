// script/DisperseCollect.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {DisperseCollect} from "../src/DisperseCollect.sol";

contract DisperseCollectScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        DisperseCollect disperseCollect = new DisperseCollect();
        
        vm.stopBroadcast();
    }
}
