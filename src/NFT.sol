// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import {MerkleProof} from 'openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol';

import './interfaces/INFT.sol';

contract NFT is ERC721, INFT, Ownable {

    uint256 internal tokenIdCounter = 1;

    bytes32 internal merkleRoot;
    uint256 internal mintFee = 0.1 ether;
    uint256 internal mintCap = 10_000;

    constructor(bytes32 _merkleRoot) ERC721("NFT", "NFT") Ownable(msg.sender) {
        merkleRoot = _merkleRoot;
    }

    /// @inheritdoc INFT
    function whitelistMint(bytes32[] calldata _merkleProof, uint256 _quantity) external {
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _quantity));
        if (!MerkleProof.verify(_merkleProof, merkleRoot, node)){
            revert InvalidProof();
        }

        _mintInternal(msg.sender, _quantity);
    }

    /// @inheritdoc INFT
    function mint(uint256 _quantity) external payable {
        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
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
    function changeMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRoot = _newMerkleRoot;
        emit MerkleRootChanged(_newMerkleRoot);
    }

    /// @inheritdoc INFT
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://example.com/";
    }
}