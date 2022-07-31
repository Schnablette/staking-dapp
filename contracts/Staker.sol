// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staker {
    
    IERC20 private token;

    uint256 immutable lockedTimeMinutes;
    // Number of whole tokens to 1 ETH
    uint256 immutable exchangeRate;

    struct userStake {
        bool canStake;
        uint256 etherStaked;
        uint256 stakeReward;
        uint256 unlockTime;
    }

    mapping(address => userStake) currentStakes;

    constructor(
        IERC20 _token,
        uint256 _exchangeRate,
        uint256 _lockedTimeMinutes
    ) {
        token = _token;
        exchangeRate = _exchangeRate;
        lockedTimeMinutes = _lockedTimeMinutes * 1 minutes;
    }

    modifier checkTime() {
        // check enough time has passed
    }

    modifier emitEvent() {
        // emit event
    }

    // User stakes token in smart contract
    function stake(uint256 _amount) external {
        // require ETH is between 1 and 100
        // define future date from which the contract can be withdrawn
        // emit event
    }

    // User withdraws full stake from contract
    function withdrawStake() external checkTime emitEvent {}

    // User withdraws full reward from contract
    function withdrawReward() external checkTime emitEvent {}
}
