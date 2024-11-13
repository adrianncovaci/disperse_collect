// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DisperseCollect is Ownable, ReentrancyGuard {
    error InvalidArrayLength();
    error TransferFailed();
    error InsufficientBalance();

    event EthDispersed(address[] recipients, uint256[] amounts);
    event TokenDispersed(address token, address[] recipients, uint256[] amounts);

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

    receive() external payable {}
}
