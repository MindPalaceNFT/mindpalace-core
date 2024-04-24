// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFT is IERC721 {
    /// @notice Invalid proof provided
    error InvalidProof();

    /// @notice Invalid mint fee provided
    error InvalidMintFee();

    /// @notice Mint cap exceeded
    error MintCapExceeded();

    /// @notice Cap exceeded for given user
    error NotEnoughMintsRemaining();

    /// @notice Emitted when the mint fee is changed
    /// @param newFee The new mint fee
    event MintFeeChanged(uint256 newFee);

    /// @notice Not enough ether in the contract to withdraw
    error NotEnoughBalance();

    /// @notice Emitted when the merkle root is changed
    /// @param newMerkleRoot The new merkle root
    event MerkleRootChanged(bytes32 newMerkleRoot);

    /// @notice Whitelisted users mint free
    /// @param merkleProof The merkle proof
    /// @param _quantity The quantity to mint
    function whitelistMint(bytes32[] calldata merkleProof, uint256 _quantity) external;

    /// @notice Mint an NFT for 0.1 ETH
    /// @param _quantity The quantity to mint
    function mint(uint256 _quantity) external payable;

    /// @notice Change the mint fee
    /// @param _newFee The new mint fee
    function changeMintFee(uint256 _newFee) external;

    /// @notice Change the merkle root
    /// @param _newMerkleRoot The new merkle root
    function changeMerkleRoot(bytes32 _newMerkleRoot) external;

    /// @notice Withdraw the ETH balance (onlyOwner)
    function withdraw() external;
}