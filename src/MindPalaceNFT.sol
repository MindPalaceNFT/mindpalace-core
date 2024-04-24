// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import './interfaces/INFT.sol';

contract MindPalaceNFT is ERC721, INFT, Ownable {

    uint256 public tokenIdCounter = 0;

    /// @notice Mapping for user mint information
    mapping(address => uint256) public reservedMints;
    mapping(address => uint256) public freeMints;
    mapping(address => uint256) public whitelistMints;

    uint256 internal totalReserved = 0;

    uint256 internal mintFee = 0.1 ether;

    /// @notice mintCap is set to 1 less than 500 to ensure only 500 exist
    uint256 internal mintCap = 499;

    /// @notice SET BEFORE DEPLOYMENT
    string internal baseURI = '';

    constructor(address _premintAddress) ERC721("MindPalaceNFT", "MP") Ownable(msg.sender) {
        _mintInternal(_premintAddress, 100);
    }

    /// @inheritdoc INFT
    function freeMint(uint256 _quantity) external {
        if (freeMints[msg.sender] < 1)
        {
            revert NotEnoughMintsRemaining();
        }

        freeMints[msg.sender] -= _quantity;

        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
        }

        if ((mintCap - tokenIdCounter) < totalReserved) {
            revert MintCapExceeded();
        }

        _mintInternal(msg.sender, _quantity);
    }

    /// @inheritdoc INFT
    function whitelistMint(uint256 _quantity) external {
        if (whitelistMints[msg.sender] < _quantity)
        {
            revert NotEnoughMintsRemaining();
        }

        whitelistMints[msg.sender] -= _quantity;

        if (msg.value != mintFee * _quantity){
            revert InvalidMintFee();
        }

        if ((mintCap - tokenIdCounter) < totalReserved) {
            revert MintCapExceeded();
        }

        _mintInternal(msg.sender, _quantity);
    }

    /// @inheritdoc INFT
    function reservedMint(uint256 _quantity) external payable {
        if (reservedMints[msg.sender] < _quantity)
        {
            revert NotEnoughMintsRemaining();
        }

        reservedMints[msg.sender] -= _quantity;

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

    function addReservedList(address[] calldata _addresses, uint256[] calldata _mintAmounts) external onlyOwner {
        assert (_addresses.length == _mintAmounts.length);
        uint256 length = _addresses.length;
        for (uint256 i; i < length; ++i){
            reservedMints[_addresses[i]] = _mintAmounts[i];
            totalReserved++;
        }
    }

    function addFreeList(address[] calldata _addresses, uint256[] calldata _mintAmounts) external onlyOwner {
        assert (_addresses.length == _mintAmounts.length);
        uint256 length = _addresses.length;
        for (uint256 i; i < length; ++i){
            freeMints[_addresses[i]] = _mintAmounts[i];
        }
    }

    function addWhitelist(address[] calldata _addresses, uint256[] calldata _mintAmounts) external onlyOwner {
        assert (_addresses.length == _mintAmounts.length);
        uint256 length = _addresses.length;
        for (uint256 i; i < length; ++i){
            whitelistMints[_addresses[i]] = _mintAmounts[i];
        }
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

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}