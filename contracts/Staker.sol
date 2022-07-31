// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staker {
    IERC20 private token;

    uint256 immutable lockedTimeMinutes;
    // Number of whole tokens to 1 ETH
    uint256 immutable exchangeRate;

    struct userStake {
        bool cannotStake;
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

    event userStaked(address indexed _user, uint256 etherStaked);

    modifier checkTime() {
        // check enough time has passed
        _;
    }

    modifier emitEvent() {
        // emit event
        _;
    }

    // User stakes token in smart contract
    function stake() external payable {
        // require they can stake
        require(
            currentStakes[msg.sender].cannotStake == false,
            "You cannot stake right now"
        );
        // require ETH is between 1 and 100
        require(msg.value >= 1 ether, "not enough ETH. Min 1 ETH");
        require(msg.value <= 100 ether, "too much ETH. Max 100 ETH");

        // create new userStake value
        userStake memory nextStake;

        nextStake.cannotStake = true;
        nextStake.etherStaked = msg.value;
        nextStake.stakeReward = msg.value * 100;
        nextStake.unlockTime = block.timestamp + lockedTimeMinutes;

        currentStakes[msg.sender] = nextStake;

        emit userStaked(msg.sender, msg.value);
    }

    // User withdraws full stake from contract
    function withdrawStake() external checkTime emitEvent {}

    // User withdraws full reward from contract
    function withdrawReward() external checkTime emitEvent {}
}
