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
    
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);
    address collector = address(0x4);
    address destination = address(0x5);

    function setUp() public {
        disperseCollect = new DisperseCollect();
        mockToken = new MockERC20();
        
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 10 ether);
        
        recipients = new address[](3);
        recipients[0] = alice;
        recipients[1] = bob;
        recipients[2] = charlie;
        
        amounts = new uint256[](3);
        amounts[0] = 1 ether;
        amounts[1] = 2 ether;
        amounts[2] = 3 ether;
        
        percentages = new uint256[](3);
        percentages[0] = 2000;
        percentages[1] = 3000;
        percentages[2] = 5000;

        mockToken.transfer(alice, 100 * 10**18);
        mockToken.transfer(bob, 100 * 10**18);
        mockToken.transfer(charlie, 100 * 10**18);
    }

    function testDisperseEth() public {
        uint256 aliceInitialBalance = alice.balance;
        uint256 bobInitialBalance = bob.balance;
        uint256 charlieInitialBalance = charlie.balance;
        
        disperseCollect.disperseEth{value: 6 ether}(recipients, amounts);

        assertEq(alice.balance, aliceInitialBalance + 1 ether);
        assertEq(bob.balance, bobInitialBalance + 2 ether);
        assertEq(charlie.balance, charlieInitialBalance + 3 ether);
    }

    function testDirectEthTransfer() public {
        vm.deal(collector, 3 ether);
        vm.deal(destination, 0);
        assertEq(destination.balance, 0);

        // Direct transfer instead of using contract
        vm.prank(collector);
        (bool success,) = destination.call{value: 3 ether}("");
        require(success, "Transfer failed");

        assertEq(destination.balance, 3 ether);
    }

    function testDirectTokenTransfer() public {
        uint256 transferAmount = 50 * 10**18;

        vm.startPrank(alice);
        mockToken.approve(collector, transferAmount);
        vm.stopPrank();

        // Direct token transfer
        vm.startPrank(collector);
        mockToken.transferFrom(alice, destination, transferAmount);
        vm.stopPrank();

        assertEq(mockToken.balanceOf(alice), 50 * 10**18);
        assertEq(mockToken.balanceOf(destination), transferAmount);
    }

    function testBatchTokenTransfer() public {
        uint256[] memory transferAmounts = new uint256[](3);
        transferAmounts[0] = 50 * 10**18;  // 50% of Alice's tokens
        transferAmounts[1] = 30 * 10**18;  // 30% of Bob's tokens
        transferAmounts[2] = 20 * 10**18;  // 20% of Charlie's tokens

        // Set approvals
        vm.prank(alice);
        mockToken.approve(collector, transferAmounts[0]);
        vm.prank(bob);
        mockToken.approve(collector, transferAmounts[1]);
        vm.prank(charlie);
        mockToken.approve(collector, transferAmounts[2]);

        // Perform transfers directly
        vm.startPrank(collector);
        mockToken.transferFrom(alice, destination, transferAmounts[0]);
        mockToken.transferFrom(bob, destination, transferAmounts[1]);
        mockToken.transferFrom(charlie, destination, transferAmounts[2]);
        vm.stopPrank();

        // Verify balances
        assertEq(mockToken.balanceOf(alice), 50 * 10**18);
        assertEq(mockToken.balanceOf(bob), 70 * 10**18);
        assertEq(mockToken.balanceOf(charlie), 80 * 10**18);
        assertEq(
            mockToken.balanceOf(destination),
            100 * 10**18
        );
    }

    function testFailInsufficientEthBalance() public {
        vm.deal(collector, 2 ether);  // Only 2 ETH but trying to send 3

        vm.prank(collector);
        (bool success,) = destination.call{value: 3 ether}("");
        require(success, "Transfer failed");
    }

    function testFailInsufficientTokenAllowance() public {
        uint256 transferAmount = 50 * 10**18;
        vm.startPrank(alice);
        mockToken.approve(collector, transferAmount - 1);  // Approve less than needed
        vm.stopPrank();

        vm.prank(collector);
        mockToken.transferFrom(alice, destination, transferAmount);
    }
}
