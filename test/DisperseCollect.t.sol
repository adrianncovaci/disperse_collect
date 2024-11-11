// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DisperseCollect.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract DisperseCollectTest is Test {
    DisperseCollect disperseCollect;
    MockERC20 mockToken;
    address[] recipients;
    uint256[] amounts;
    uint256[] percentages;

    function setUp() public {
        disperseCollect = new DisperseCollect();
        mockToken = new MockERC20();
        
        recipients = new address[](3);
        recipients[0] = address(0x1);
        recipients[1] = address(0x2);
        recipients[2] = address(0x3);
        
        amounts = new uint256[](3);
        amounts[0] = 1 ether;
        amounts[1] = 2 ether;
        amounts[2] = 3 ether;
        
        percentages = new uint256[](3);
        percentages[0] = 2000; // 20%
        percentages[1] = 3000; // 30%
        percentages[2] = 5000; // 50%
    }

    function testDisperseEth() public {
        disperseCollect.disperseEth{value: 6 ether}(recipients, amounts);
        assertEq(address(0x1).balance, 1 ether);
        assertEq(address(0x2).balance, 2 ether);
        assertEq(address(0x3).balance, 3 ether);
    }
}
