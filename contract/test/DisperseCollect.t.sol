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
        
        vm.deal(alice, 0);
        vm.deal(bob, 0);
        vm.deal(charlie, 0);
        
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
        assertEq(alice.balance, 0);
        assertEq(bob.balance, 0);
        assertEq(charlie.balance, 0);
        
        disperseCollect.disperseEth{value: 6 ether}(recipients, amounts);

        assertEq(alice.balance, 1 ether);
        assertEq(bob.balance, 2 ether);
        assertEq(charlie.balance, 3 ether);
    }

    function testCollectEth() public {
        vm.deal(collector, 3 ether);

        address[] memory fromAddresses = new address[](3);
        fromAddresses[0] = alice;
        fromAddresses[1] = bob;
        fromAddresses[2] = charlie;

        uint256 totalAmount = 3 ether;
        
        vm.deal(destination, 0);
        assertEq(destination.balance, 0);

        vm.prank(collector);
        disperseCollect.collectEth{value: totalAmount}(fromAddresses, payable(destination));

        assertEq(destination.balance, totalAmount);
    }

    function testTokenCollection() public {
        vm.startPrank(alice);
        disperseCollect.approveCollection(address(mockToken), collector, 5000); // 50%
        mockToken.approve(address(disperseCollect), 50 * 10**18);
        vm.stopPrank();

        vm.startPrank(bob);
        disperseCollect.approveCollection(address(mockToken), collector, 3000); // 30%
        mockToken.approve(address(disperseCollect), 30 * 10**18);
        vm.stopPrank();

        vm.startPrank(charlie);
        disperseCollect.approveCollection(address(mockToken), collector, 2000); // 20%
        mockToken.approve(address(disperseCollect), 20 * 10**18);
        vm.stopPrank();

        address[] memory fromAddresses = new address[](3);
        fromAddresses[0] = alice;
        fromAddresses[1] = bob;
        fromAddresses[2] = charlie;

        assertEq(mockToken.balanceOf(alice), 100 * 10**18);
        assertEq(mockToken.balanceOf(bob), 100 * 10**18);
        assertEq(mockToken.balanceOf(charlie), 100 * 10**18);

        vm.prank(collector);
        disperseCollect.collectToken(address(mockToken), fromAddresses, destination);

        assertEq(mockToken.balanceOf(alice), 50 * 10**18);
        assertEq(mockToken.balanceOf(bob), 70 * 10**18);
        assertEq(mockToken.balanceOf(charlie), 80 * 10**18);
        assertEq(
            mockToken.balanceOf(destination),
            100 * 10**18
        );
    }

    function testApproveCollection() public {
        vm.startPrank(alice);
        disperseCollect.approveCollection(address(mockToken), collector, 5000);
        vm.stopPrank();

        (bool approved, uint256 percentage) = disperseCollect.collectionApprovals(
            address(mockToken),
            alice,
            collector
        );

        assertTrue(approved);
        assertEq(percentage, 5000);
    }

    function testRevokeCollection() public {
        vm.startPrank(alice);
        disperseCollect.approveCollection(address(mockToken), collector, 5000);
        disperseCollect.revokeCollection(address(mockToken), collector);
        vm.stopPrank();

        (bool approved, uint256 percentage) = disperseCollect.collectionApprovals(
            address(mockToken),
            alice,
            collector
        );

        assertFalse(approved);
        assertEq(percentage, 0);
    }

    function testFailApproveInvalidPercentage() public {
        vm.prank(alice);
        disperseCollect.approveCollection(address(mockToken), collector, 15000); // 150%
    }

    function testFailCollectTokenWithoutApproval() public {
        address[] memory fromAddresses = new address[](1);
        fromAddresses[0] = alice;

        vm.prank(collector);
        disperseCollect.collectToken(
            address(mockToken),
            fromAddresses,
            destination
        );
    }
}
