// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import './interfaces/INFT.sol';
import './interfaces/IStaking.sol';

contract Staking is IStaking, Ownable {

    INFT internal nft;
    IERC20 internal rewardToken;

    mapping(uint256 => address) internal ownerOf;

    mapping(address => StakeInfo) internal stakeInfo;

    struct StakeInfo {
        uint256 rewards;
        uint256 lastUpdateTime;
        uint256 totalStaked;
    }

    constructor (address _nft, address _rewardToken) Ownable(msg.sender) {
        nft = INFT(_nft);
        rewardToken = IERC20(_rewardToken);
    }

    modifier updateReward(address _account) {
        StakeInfo storage userStakeInfo = stakeInfo[_account];
        userStakeInfo.rewards = earned(_account);
        userStakeInfo.lastUpdateTime = block.timestamp;
        _;
    }

    /// @inheritdoc IStaking
    function stake(uint256[] calldata _tokenIds) external updateReward(msg.sender) {
        for (uint256 i; i < _tokenIds.length; ++i) {
            uint256 tokenId = _tokenIds[i];

            nft.transferFrom(msg.sender, address(this), tokenId);

            ownerOf[tokenId] = msg.sender;

            emit Staked(msg.sender, tokenId);
        }
    }

    /// @inheritdoc IStaking
    function unstake(uint256[] calldata _tokenIds) external updateReward(msg.sender) {
        for (uint256 i; i < _tokenIds.length; ++i) {
            uint256 tokenId = _tokenIds[i];

            if (ownerOf[tokenId] != msg.sender){
                revert InvalidOwner();
            }

            nft.transferFrom(address(this), msg.sender, tokenId);

            ownerOf[tokenId] = address(0);

            emit Unstaked(msg.sender, tokenId);
        }
    }

    /// @inheritdoc IStaking
    function harvest() external updateReward(msg.sender) {
        StakeInfo storage userStakeInfo = stakeInfo[msg.sender];

        uint256 rewardsToClaim = userStakeInfo.rewards;

        if (rewardsToClaim == 0) {
            revert NoRewards();
        }

        userStakeInfo.rewards = 0;

        rewardToken.transfer(msg.sender, rewardsToClaim);

        emit Harvested(msg.sender, rewardsToClaim);
    }

    /// @inheritdoc IStaking
    function earned(address _account) public view returns (uint256) {
        StakeInfo storage userStakeInfo = stakeInfo[_account];

        uint256 timeDelta = block.timestamp - userStakeInfo.lastUpdateTime;
        // TODO: implement
        uint256 rewardRate = 0;

        return userStakeInfo.rewards + (userStakeInfo.totalStaked * rewardRate * timeDelta);
    }

    function _rewardPerToken() internal view returns (uint256) {
        // TODO: implement
    }

    /// @inheritdoc IStaking
    function changeRewardToken(address _newRewardToken) external onlyOwner {
        rewardToken = IERC20(_newRewardToken);
    }
}