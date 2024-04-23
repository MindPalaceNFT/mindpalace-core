// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

import './interfaces/INFT.sol';

contract MindPalaceNFT is ERC721, INFT, Ownable {

    uint256 internal tokenIdCounter = 1;

    /// @notice Tree of addresses who have a reserved free mint.
    bytes32 internal merkleRootFreeReserved;

    bytes32 internal merkleRootFreeStandard;

    /// @notice Tree of addresses who may mint during whitelist mint.
    bytes32 internal merkleRootWhitelist;

    uint256 internal mintFee = 0.1 ether;
    uint256 internal mintCap = 500;
    uint256 internal totalReserved = 134;

    /// @notice SET BEFORE DEPLOYMENT
    string internal baseURI = '';

    constructor(bytes32 _merkleRootFree, bytes32 _merkleRootWhitelist, address _premintAdress) ERC721("NFT", "NFT") Ownable(msg.sender) {
        merkleRootWhitelist = _merkleRootWhitelist;
        merkleRootFree = _merkleRootFree;
        _mintInternal(_premintAddress, 100);
    }

    /// @inheritdoc INFT
    function freeMint(bytes32[] calldata _merkleProof, uint256 _quantity) external {
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _quantity));
        if (!MerkleProof.verify(_merkleProof, merkleRootWhitelist, node)){
            revert InvalidProof();
        }

        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
        }

        if ((mintCap - tokenIdCounter) < totalReserved) {
            revert MintCapExceeded();
        }

        _mintInternal(msg.sender, _quantity);
    }

    /// @inheritdoc INFT
    function whitelistMint(bytes32[] calldata _merkleProof, uint256 _quantity) external {
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _quantity));
        if (!MerkleProof.verify(_merkleProof, merkleRootWhitelist, node)){
            revert InvalidProof();
        }

        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
        }

        if ((mintCap - tokenIdCounter) < totalReserved) {
            revert MintCapExceeded();
        }

        _mintInternal(msg.sender, _quantity);
    }

    /// @inheritdoc INFT
    function reservedMint(bytes32[] calldata _merkleProof) external payable {
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _quantity));
        if (!MerkleProof.verify(_merkleProof, merkleRootFree, node)){
            revert InvalidProof();
        }

        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
        }

        if ((mintCap - tokenIdCounter) < totalReserved) {
            revert MintCapExceeded();
        }

        _mintInternal(msg.sender, _quantity);

        totalReserved--;
    }

    /// @inheritdoc INFT
    function publicMint(uint256 _quantity) external payable {
        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
        }
        
        if ((mintCap - tokenIdCounter) < totalReserved) {
            revert MintCapExceeded();
        }

        _mintInternal(msg.sender, _quantity);
    }

    function _mintInternal(address _to, uint256 _quantity) internal {
        for (uint256 i; i < _quantity; ++i) {
            uint256 tokenId = tokenIdCounter;
            if (tokenId > mintCap){
                revert MintCapExceeded();
            }
            _mint(_to, tokenId);

            unchecked {
                tokenIdCounter += 1;
            }
        }
    }

    /// @inheritdoc INFT
    function changeMintFee(uint256 _newFee) external onlyOwner {
        mintFee = _newFee;
        emit MintFeeChanged(_newFee);
    }

    /// @inheritdoc INFT
    function changeMerkleRootFreeReserved(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRootFreeReserved = _newMerkleRoot;
        emit MerkleRootChanged(_newMerkleRoot);
    }

    /// @inheritdoc INFT
    function changeMerkleRootFreeStandard(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRootFreeStandard = _newMerkleRoot;
        emit MerkleRootChanged(_newMerkleRoot);
    }

    /// @inheritdoc INFT
    function changeMerkleRootWhitelist(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRootWhitelist = _newMerkleRoot;
        emit MerkleRootChanged(_newMerkleRoot);
    }

    function withdraw(uint256 _ether) external onlyOwner {
        if (address(this).balance < _ether) {
            revert NotEnoughBalance();
        }
        payable(msg.sender).transfer(_ether);
    }

    function withrawAll() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function changeURI(string calldata _newURI) external onlyOwner {
        baseURI = _newURI;
    }

    function _baseURI() internal override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256)
}