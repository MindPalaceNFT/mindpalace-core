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

interface IBlastPoints {
  function configurePointsOperator(address operator) external;
}

/**
  * @title Generate Points by Staking ETH
  * @author haruxe.eth
 **/
contract Staking is IStaking, Ownable {

    mapping(address => StakeInfo) public stakeInfo;
    mapping(address => bool) public staked;

    uint256 public rewardRate;
    uint256 public totalStaked;

    bool public stakeLimitActive = true;
    bool public allowUnstaking = false;

    address public constant BLAST_POINTS = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;

    uint256 public constant MINIMUM_STAKE_FEE = 0.1 ether;

    constructor (uint256 _rewardRate, address _pointsOperator) Ownable(msg.sender) {
        rewardRate = _rewardRate;
        IBlastPoints(BLAST_POINTS).configurePointsOperator(_pointsOperator);
    }

    /// @notice Only for emergency purposes
    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        payable(owner()).transfer(_amount);
    }

    /// @inheritdoc IStaking
    function stake() external payable {
        _stake(address(0));
    }

    /// @inheritdoc IStaking
    function stakeWithReferral(address referer) external payable {
        _stake(referer);
    }

    /// @inheritdoc IStaking
    function getReferredUsers(address _account) external view returns (address[] memory) {
        return stakeInfo[_account].referredUsers;
    }

    function _stake(address _referer) internal {
        if (msg.value < MINIMUM_STAKE_FEE){
            revert InvalidStakeFee();
        }

        // The referer now gets 25% of the referal's rewards bonus
        if (_referer != address(0)){
            StakeInfo storage referrerStakeInfo = stakeInfo[_referer];
            referrerStakeInfo.referredUsers.push(msg.sender);
        }

        StakeInfo storage userStakeInfo = stakeInfo[msg.sender];
        userStakeInfo.rewardsStored += _earned(msg.sender);
        userStakeInfo.stakedAt = block.timestamp;
        userStakeInfo.totalStaked += msg.value;
        staked[msg.sender] = true;

        emit Staked(msg.sender, msg.value);
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

    /// @notice Unstake for a user
    /// @param _staker The address of the staker
    function unstakeFor(address _staker) external onlyOwner {
        StakeInfo storage userStakeInfo = stakeInfo[_staker];
        uint256 totalStakedForUser = userStakeInfo.totalStaked;

        payable(_staker).transfer(totalStakedForUser);
        
        userStakeInfo.rewardsStored += _earned(_staker);
        userStakeInfo.stakedAt = 0;
        userStakeInfo.totalStaked = 0;
        staked[_staker] = false;

        emit Unstaked(_staker, totalStakedForUser);
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