// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {

    constructor(uint256 _mintAmount) ERC20("RewardToken", "RT") {
        _mint(msg.sender, _mintAmount);
    }
}