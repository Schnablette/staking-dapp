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

    event userStaked(address indexed _user, uint256 etherStaked);
    event userWithdrawStake(address indexed _user, uint256 etherStaked);
    event userWithdrawReward(address indexed _user, uint256 stakeReward);

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
        require(
            block.timestamp >= currentStakes[msg.sender].unlockTime,
            "It's not time to withdraw yet"
        );
        _;
    }

    modifier checkRestake() {
        _;
        if (
            currentStakes[msg.sender].etherStaked == 0 &&
            currentStakes[msg.sender].stakeReward == 0
        ) {
            currentStakes[msg.sender].cannotStake = false;
        }
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
    function withdrawStake() external payable checkTime checkRestake {
        require(
            currentStakes[msg.sender].etherStaked > 0,
            "no value to unstake"
        );

        uint256 userStakedAmount = currentStakes[msg.sender].etherStaked;
        currentStakes[msg.sender].etherStaked = 0;

        (bool success, ) = msg.sender.call{value: userStakedAmount}("");
        require(success, "Call Failed");

        emit userWithdrawStake(msg.sender, userStakedAmount);

        // run modifier to check restake
    }

    // User withdraws full reward from contract
    function withdrawReward() external checkTime checkRestake {
        require(
            currentStakes[msg.sender].stakeReward > 0,
            "no value to unstake"
        );

        uint256 userRewardAmount = currentStakes[msg.sender].stakeReward;
        currentStakes[msg.sender].stakeReward = 0;

        token.transfer(msg.sender, userRewardAmount);

        emit userWithdrawReward(msg.sender, userRewardAmount);
    }
}
