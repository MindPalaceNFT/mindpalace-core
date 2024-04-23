pragma solidity 0.8.23;



// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


interface INFT is IERC721 {
    /// @notice Invalid proof provided
    error InvalidProof();

    /// @notice Invalid mint fee provided
    error InvalidMintFee();

    /// @notice Mint cap exceeded
    error MintCapExceeded();

    /// @notice Emitted when the mint fee is changed
    /// @param newFee The new mint fee
    event MintFeeChanged(uint256 newFee);

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

// SPDX-License-Identifier: UNLICENSED
/*$$\      $$\ $$\                 $$\ $$$$$$$\           $$\                               
  $$$\    $$$ |\__|                $$ |$$  __$$\          $$ |                              
  $$$$\  $$$$ |$$\ $$$$$$$\   $$$$$$$ |$$ |  $$ |$$$$$$\  $$ | $$$$$$\   $$$$$$$\  $$$$$$\  
  $$\$$\$$ $$ |$$ |$$  __$$\ $$  __$$ |$$$$$$$  |\____$$\ $$ | \____$$\ $$  _____|$$  __$$\ 
  $$ \$$$  $$ |$$ |$$ |  $$ |$$ /  $$ |$$  ____/ $$$$$$$ |$$ | $$$$$$$ |$$ /      $$$$$$$$ |
  $$ |\$  /$$ |$$ |$$ |  $$ |$$ |  $$ |$$ |     $$  __$$ |$$ |$$  __$$ |$$ |      $$   ____|
  $$ | \_/ $$ |$$ |$$ |  $$ |\$$$$$$$ |$$ |     \$$$$$$$ |$$ |\$$$$$$$ |\$$$$$$$\ \$$$$$$$\ 
  \__|     \__|\__|\__|  \__| \_______|\__|      \_______|\__| \_______| \_______| \_______|*/
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