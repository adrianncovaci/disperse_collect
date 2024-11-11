// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DisperseCollect is Ownable, ReentrancyGuard {
    error InvalidArrayLength();
    error TransferFailed();
    error InsufficientBalance();
    error InvalidPercentage();

    event EthDispersed(address[] recipients, uint256[] amounts);
    event TokenDispersed(address token, address[] recipients, uint256[] amounts);
    event EthCollected(address[] from, address to, uint256 totalAmount);
    event TokenCollected(address token, address[] from, address to, uint256 totalAmount);

    constructor() Ownable(msg.sender) {}

    function disperseEth(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external payable nonReentrant {
        if (recipients.length != amounts.length) revert InvalidArrayLength();
        
        uint256 total = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }
        
        if (msg.value != total) revert InsufficientBalance();

        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = recipients[i].call{value: amounts[i]}("");
            if (!success) revert TransferFailed();
        }

        emit EthDispersed(recipients, amounts);
    }

    function disperseEthByPercentage(
        address[] calldata recipients,
        uint256[] calldata percentages
    ) external payable nonReentrant {
        if (recipients.length != percentages.length) revert InvalidArrayLength();
        
        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < percentages.length; i++) {
            totalPercentage += percentages[i];
        }
        
        if (totalPercentage != 100_00) revert InvalidPercentage(); // Expecting percentages multiplied by 100

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = (msg.value * percentages[i]) / 100_00;
            (bool success, ) = recipients[i].call{value: amount}("");
            if (!success) revert TransferFailed();
        }

        emit EthDispersed(recipients, percentages);
    }

    function disperseToken(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external nonReentrant {
        if (recipients.length != amounts.length) revert InvalidArrayLength();
        
        IERC20 tokenContract = IERC20(token);
        uint256 total = 0;
        
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }

        if (tokenContract.allowance(msg.sender, address(this)) < total) 
            revert InsufficientBalance();

        for (uint256 i = 0; i < recipients.length; i++) {
            bool success = tokenContract.transferFrom(
                msg.sender,
                recipients[i],
                amounts[i]
            );
            if (!success) revert TransferFailed();
        }

        emit TokenDispersed(token, recipients, amounts);
    }

    function disperseTokenByPercentage(
        address token,
        address[] calldata recipients,
        uint256[] calldata percentages,
        uint256 totalAmount
    ) external nonReentrant {
        if (recipients.length != percentages.length) revert InvalidArrayLength();
        
        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < percentages.length; i++) {
            totalPercentage += percentages[i];
        }
        
        if (totalPercentage != 100_00) revert InvalidPercentage();

        IERC20 tokenContract = IERC20(token);
        if (tokenContract.allowance(msg.sender, address(this)) < totalAmount) 
            revert InsufficientBalance();

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = (totalAmount * percentages[i]) / 100_00;
            bool success = tokenContract.transferFrom(
                msg.sender,
                recipients[i],
                amount
            );
            if (!success) revert TransferFailed();
        }

        emit TokenDispersed(token, recipients, percentages);
    }

    function collectEth(
        address payable to
    ) external payable nonReentrant {
        address[] memory fromAddresses = new address[](1);
        fromAddresses[0] = msg.sender;
        
        emit EthCollected(fromAddresses, to, msg.value);
        (bool success, ) = to.call{value: msg.value}("");
        if (!success) revert TransferFailed();
    }

    function collectToken(
        address token,
        address to,
        uint256 amount
    ) external nonReentrant {
        address[] memory fromAddresses = new address[](1);
        fromAddresses[0] = msg.sender;

        IERC20 tokenContract = IERC20(token);
        if (tokenContract.allowance(msg.sender, address(this)) < amount) 
            revert InsufficientBalance();

        bool success = tokenContract.transferFrom(msg.sender, to, amount);
        if (!success) revert TransferFailed();

        emit TokenCollected(token, fromAddresses, to, amount);
    }

    receive() external payable {}
}
