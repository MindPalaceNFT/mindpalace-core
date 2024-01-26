// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Staking} from "../src/Staking.sol";

contract CounterTest is Test {
    Staking staking;

    address constant owner = address(1);
    address constant alice = address(2);
    address constant bob = address(3);

    /// @notice 1 ether per second
    uint256 constant rewardRate = 1 ether;

    function setUp() public {
        vm.prank(owner);
        staking = new Staking(rewardRate);
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_can_stake() public {
        vm.prank(alice);
        staking.stake{value: .1 ether}();
        assertTrue(staking.staked(alice));
    }

    function test_can_refer() public {
        vm.prank(alice);
        staking.stakeWithReferral{value: .1 ether}(bob);
        assertTrue(staking.staked(alice));
        assertTrue(staking.getReferredUsers(bob)[0] == alice);
    }

    function test_can_unstake() public {
        vm.prank(alice);
        staking.stake{value: .1 ether}();
        vm.prank(owner);
        staking.changeUnstakingActive(true);
        vm.prank(alice);
        staking.unstake();
        assertFalse(staking.staked(alice));
    }

    function test_properly_generates_points_for_one_user() public {
        vm.prank(alice);
        staking.stake{value: .1 ether}();
        vm.warp(7 days);
        uint256 alicePoints = staking.totalEarned(alice);
        assertTrue(alicePoints > 0);
        uint256 expectedPoints = ((rewardRate / 10) * 7 days);
        assertApproxEqAbs(alicePoints, expectedPoints, 1e17);
    }

    function test_properly_generates_points_for_two_users() public {
        vm.prank(alice);
        staking.stake{value: .1 ether}();
        vm.prank(bob);
        staking.stake{value: .1 ether}();
        vm.warp(7 days);
        uint256 alicePoints = staking.totalEarned(alice);
        uint256 bobPoints = staking.totalEarned(bob);
        assertTrue(alicePoints > 0);
        assertTrue(bobPoints > 0);
        uint256 expectedPoints = ((rewardRate / 10) * 7 days);
        assertApproxEqAbs(alicePoints, expectedPoints, 1e17);
        assertApproxEqAbs(bobPoints, expectedPoints, 1e17);
    }

    /// @notice Ensures that a user can refer another user and get 25% of their points as a bonus
    function test_referral_properly_gives_bonus() public {
        vm.prank(alice);
        staking.stakeWithReferral{value: .1 ether}(bob);
        vm.prank(bob);
        staking.stake{value: .1 ether}();
        vm.warp(7 days);
        uint256 alicePoints = staking.totalEarned(alice);
        uint256 bobPoints = staking.totalEarned(bob);
        assertTrue(alicePoints > 0);
        assertTrue(bobPoints > 0);
        uint256 expectedPoints = ((rewardRate / 10) * 7 days) + (((rewardRate / 10) * 7 days) / 4);
        assertApproxEqAbs(bobPoints, expectedPoints, 1e18);
    }
}
