// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

interface IStaking {
    /// @notice Invalid owner
    error InvalidOwner();

    /// @notice No rewards
    error NoRewards();

    /// @notice Emitted when a user harvests rewards
    /// @param staker The address of the staker
    /// @param amount The amount of rewards harvested
    event Harvested(address indexed staker, uint256 amount);

    /// @notice Emitted when an NFT is staked
    /// @param staker The address of the staker
    /// @param tokenId The token ID of the staked NFT
    event Staked(address indexed staker, uint256 indexed tokenId);
    
    /// @notice Emitted when an NFT is unstaked
    /// @param staker The address of the staker
    /// @param tokenId The token ID of the unstaked NFT
    event Unstaked(address indexed staker, uint256 indexed tokenId);
    
    /// @notice Stake an NFT
    /// @param _tokenIds The token IDs to stake
    function stake(uint256[] calldata _tokenIds) external;
    
    /// @notice Unstake an NFT
    /// @param _tokenIds The token IDs to unstake
    function unstake(uint256[] calldata _tokenIds) external;

    /// @notice Harvest rewards
    function harvest() external;

    /// @notice Change the reward token
    /// @param _newRewardToken The new reward token
    function changeRewardToken(address _newRewardToken) external;

    /// @notice Earned rewards
    /// @param _account The account to check
    /// @return The amount of rewards earned
    function earned(address _account) external view returns (uint256);
}