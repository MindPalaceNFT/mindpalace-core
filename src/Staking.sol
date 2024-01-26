// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

/*$$\      $$\ $$\                 $$\ $$$$$$$\           $$\                               
  $$$\    $$$ |\__|                $$ |$$  __$$\          $$ |                              
  $$$$\  $$$$ |$$\ $$$$$$$\   $$$$$$$ |$$ |  $$ |$$$$$$\  $$ | $$$$$$\   $$$$$$$\  $$$$$$\  
  $$\$$\$$ $$ |$$ |$$  __$$\ $$  __$$ |$$$$$$$  |\____$$\ $$ | \____$$\ $$  _____|$$  __$$\ 
  $$ \$$$  $$ |$$ |$$ |  $$ |$$ /  $$ |$$  ____/ $$$$$$$ |$$ | $$$$$$$ |$$ /      $$$$$$$$ |
  $$ |\$  /$$ |$$ |$$ |  $$ |$$ |  $$ |$$ |     $$  __$$ |$$ |$$  __$$ |$$ |      $$   ____|
  $$ | \_/ $$ |$$ |$$ |  $$ |\$$$$$$$ |$$ |     \$$$$$$$ |$$ |\$$$$$$$ |\$$$$$$$\ \$$$$$$$\ 
  \__|     \__|\__|\__|  \__| \_______|\__|      \_______|\__| \_______| \_______| \_______|*/

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import './interfaces/INFT.sol';
import './interfaces/IStaking.sol';

/**
  * @title Generate Points by Staking ETH
  * @author haruxe.eth
 **/
contract Staking is IStaking, Ownable, ReentrancyGuard {

    mapping(address => StakeInfo) public stakeInfo;
    mapping(address => bool) public staked;

    uint256 public rewardRate;
    uint256 public totalStaked;

    bool public stakeLimitActive = true;
    bool public allowUnstaking = false;
    uint256 public constant INITIAL_STAKE_FEE = 0.1 ether;

    constructor (uint256 _rewardRate) Ownable(msg.sender) {
        rewardRate = _rewardRate;
    }

    modifier unstakeActive() {
        if (!allowUnstaking){
            revert UnstakeInactive();
        }
        _;
    }

    /// @inheritdoc IStaking
    function stake() external payable nonReentrant {
        _stake(address(0));
    }

    /// @inheritdoc IStaking
    function stakeWithReferral(address referer) external payable nonReentrant {
        _stake(referer);
    }

    /// @inheritdoc IStaking
    function unstake() external nonReentrant unstakeActive {
        if (!staked[msg.sender]){
            revert NotStaked();
        }

        StakeInfo storage userStakeInfo = stakeInfo[msg.sender];
        uint256 totalStakedForUser = userStakeInfo.totalStaked;

        payable(msg.sender).transfer(totalStakedForUser);
        
        userStakeInfo.rewardsStored += _earned(msg.sender);
        userStakeInfo.stakedAt = 0;
        staked[msg.sender] = false;
        totalStakedForUser -= totalStakedForUser;
        totalStaked -= totalStakedForUser;

        emit Unstaked(msg.sender);
    }

    /// @inheritdoc IStaking
    function totalEarned(address _account) external view returns (uint256) {
        uint256 _totalEarned = _earned(_account);
        for (uint256 i; i < stakeInfo[_account].referredUsers.length; ++i){
            address referredUser = stakeInfo[_account].referredUsers[i];
            _totalEarned += _earned(referredUser) / 4;
        }
        return _totalEarned;
    }

    /// @inheritdoc IStaking
    function earned(address _account) external view returns (uint256) {
        return _earned(_account);
    }

    /// @inheritdoc IStaking
    function getReferredUsers(address _account) external view returns (address[] memory) {
        return stakeInfo[_account].referredUsers;
    }

    function _stake(address _referer) internal {
        if (stakeLimitActive){
            if (staked[msg.sender]){
                revert AlreadyStaked();
            }
            if (msg.value != INITIAL_STAKE_FEE){
                revert InvalidStakeFee();
            }
        }

        // The referer now gets 30% of the referal's rewards bonus
        if (_referer != address(0)){
            StakeInfo storage referrerStakeInfo = stakeInfo[_referer];
            referrerStakeInfo.referredUsers.push(msg.sender);
        }

        StakeInfo storage userStakeInfo = stakeInfo[msg.sender];
        userStakeInfo.rewardsStored += _earned(msg.sender);
        userStakeInfo.stakedAt = block.timestamp;
        userStakeInfo.totalStaked += msg.value;
        staked[msg.sender] = true;
        totalStaked += msg.value;

        emit Staked(msg.sender);
    }

    function _earned(address _account) internal view returns (uint256) {
        StakeInfo storage userStakeInfo = stakeInfo[_account];

        if (userStakeInfo.stakedAt == 0){
            return userStakeInfo.rewardsStored;
        }

        uint256 timeDelta = block.timestamp - userStakeInfo.stakedAt;

        return userStakeInfo.rewardsStored + ((userStakeInfo.totalStaked * rewardRate * timeDelta) / 1e18);
    }

    function changeRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    function changeUnstakingActive(bool _allowUnstaking) external onlyOwner {
        allowUnstaking = _allowUnstaking;
    }

    function changeStakeLimitActive(bool _stakeLimitActive) external onlyOwner {
        stakeLimitActive = _stakeLimitActive;
    }
}