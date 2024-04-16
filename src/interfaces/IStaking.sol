// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

interface IStaking {
    /// @notice Invalid owner
    error InvalidOwner();

    /// @notice Emitted when ETH is staked
    /// @param staker The address of the staker
    /// @param amount The amount of ETH staked
    event Staked(address indexed staker, uint256 amount);
    
    /// @notice Emitted when ETH is staked
    /// @param staker The address of the staker
    /// @param amount The amount of ETH staked
    event Unstaked(address indexed staker, uint256 amount);

    /// @notice Invalid stake fee
    error InvalidStakeFee();

    /// @notice Not staked
    error NotStaked();

    /// @notice Stake your ETH
    function stake() external payable;

    /// @notice Stake your ETH with a referral
    /// @param referer The address of the referrer
    function stakeWithReferral(address referer) external payable;

    /// @notice Earned points for an account
    /// @param _account The account to check
    /// @return The amount of points earned
    function earned(address _account) external view returns (uint256);

    /// @notice Total earned points for an account
    /// @param _account The account to check
    function totalEarned(address _account) external view returns (uint256);

    /// @notice Get the users referred by an account
    /// @param _account The account to check
    function getReferredUsers(address _account) external view returns (address[] memory);

    struct StakeInfo {
        uint256 stakedAt;
        uint256 rewardsStored;
        uint256 totalStaked;
        address[] referredUsers;
    }
}