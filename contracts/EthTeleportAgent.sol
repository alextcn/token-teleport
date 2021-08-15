// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

interface IERC20Query {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the initial owner.
     */
    function initializeOwnable(address ownerAddr_) internal {
        _setOwner(ownerAddr_);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IWrappedToken {
    function initialize(string calldata name, string calldata symbol, uint8 decimals, address owner) external;
    function mintTo(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint256 amount) external returns (bool);
}

contract EthTeleportAgent is Ownable, Initializable {
    using SafeERC20 for IERC20;
    using Address for address;

    struct OriginalToken {
        bool registered;
        uint256 chainId;
        address addr;
    }

    mapping(address/*original token address in present chain*/ => bool/*registered*/) public originalTokens_;
    mapping(address/*wrapped token address*/ => OriginalToken) public wrappedToOriginalTokens_;
    mapping(bytes32/*other chain start tx hash*/ => bool/*filled*/) public filledTeleports_;
    mapping(address/*other chain token address*/ => mapping(uint256/*other chain id*/ => address/*wrapped token address*/)) public otherChainTokensToWrappedTokens_;
    mapping(uint256/*original chain id*/ => mapping(address /*original token address*/ => address/*wrapped token address*/)) public originalToWrappedTokens_;
    mapping(address/*token address in present chain*/ => mapping(uint256/*to chain id*/ => bool/*registered*/)) public routesFromTokenToChain_;
    address public wrappedTokenImplementation_;
    uint256 public registerFee_;
    uint256 public teleportFee_;

    string private constant ERROR_FEE_MISMATCH = "fee mismatch";
    string private constant ERROR_TELEPORT_PAIR_NOT_CREATED = "teloport pair is not created";
    string private constant ERROR_TELEPORT_TX_FILLED_ALREADY = "teleport tx filled already";

    event TeleportPairRegistered(
        address indexed sponsor,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed presentChainTokenAddr,
        uint256 toChainId,
        string name,
        string symbol,
        uint8 decimals,
        uint256 feeAmount);

    event TeleportPairCreated(
        uint256 fromChainId,
        address indexed fromChainTokenAddr,
        bytes32 fromChainRegisterTxHash,
        address indexed originalTokenAddr,
        uint256 originalTokenChainId,
        address indexed wrappedTokenAddr,
        string name,
        string symbol,
        uint8 decimals);

    event TeleportStarted(
        address indexed fromAddr,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed tokenAddr,
        uint256 amount,
        uint256 toChainId,
        uint256 feeAmount);

    event TeleportFinished(
        uint256 fromChainId,
        address indexed fromChainTokenAddr,
        bytes32 fromChainStartTxHash,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed toAddress,
        uint256 amount);

    function initialize(
        uint256 _registerFee,
        uint256 _teleportFee,
        address payable _ownerAddr,
        address _wrappedTokenImpl) external virtual initializer {

        require(_ownerAddr != address(0), "zero owner address");
        initializeOwnable(_ownerAddr);

        registerFee_ = _registerFee;
        teleportFee_ = _teleportFee;
        wrappedTokenImplementation_ = _wrappedTokenImpl;
    }

    function _ensureNotContract(address _addr) private view {
        require(!_addr.isContract(), "contract not allowed to teleport");
        require(_addr == tx.origin, "proxy not allowed to teleport");
    }

    function setRegisterFee(uint256 _registerFee) onlyOwner external {
        registerFee_ = _registerFee;
    }

    function setTeleportFee(uint256 _teleportFee) onlyOwner external {
        teleportFee_ = _teleportFee;
    }

    function registerTeleportPair(address _presentChainTokenAddr, uint256 _toChainId) payable external returns (bool) {
        require(_presentChainTokenAddr.isContract(), "given address is not a contract");
        require(!routesFromTokenToChain_[_presentChainTokenAddr][_toChainId], "already registered");
        require(msg.value >= registerFee_, ERROR_FEE_MISMATCH);

        if (msg.value != 0) {
            payable(owner()).transfer(msg.value);
        }

        OriginalToken memory originalToken = wrappedToOriginalTokens_[_presentChainTokenAddr];

        if (!originalToken.registered) {
            if (!originalTokens_[_presentChainTokenAddr]) {
                originalTokens_[_presentChainTokenAddr] = true;
            }

            originalToken.chainId = block.chainid;
            originalToken.addr = _presentChainTokenAddr;
        }

        require(originalToken.chainId != _toChainId, "no need to register teleport to original chain");

        string memory name = IERC20Query(_presentChainTokenAddr).name();
        string memory symbol = IERC20Query(_presentChainTokenAddr).symbol();
        uint8 decimals = IERC20Query(_presentChainTokenAddr).decimals();

        require(bytes(name).length > 0, "empty token name");
        require(bytes(symbol).length > 0, "empty token symbol");

        routesFromTokenToChain_[_presentChainTokenAddr][_toChainId] = true;

        emit TeleportPairRegistered(_msgSender(), originalToken.chainId, originalToken.addr, _presentChainTokenAddr, _toChainId, name, symbol, decimals, msg.value);

        return true;
    }

    function createTeleportPair(
        uint256 _fromChainId,
        address _fromChainTokenAddr,
        bytes32 _fromChainRegisterTxHash,
        address _originalTokenAddr,
        uint256 _originalTokenChainId,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals) onlyOwner external returns (address) {

        require(otherChainTokensToWrappedTokens_[_fromChainTokenAddr][_fromChainId] == address(0x0), "pair already created");
        require(block.chainid != _originalTokenChainId, "no need to register teleport to original chain");

        address wrappedTokenAddr = originalToWrappedTokens_[_originalTokenChainId][_originalTokenAddr];

        if (wrappedTokenAddr == address(0x0)) {

            address proxyToken = _deployMinimalProxy(wrappedTokenImplementation_);
            IWrappedToken token = IWrappedToken(proxyToken);
            token.initialize(_name, _symbol, _decimals, address(this));

            wrappedTokenAddr = address(token);

            originalToWrappedTokens_[_originalTokenChainId][_originalTokenAddr] = wrappedTokenAddr;

            OriginalToken storage originalToken = wrappedToOriginalTokens_[wrappedTokenAddr];
            require(!originalToken.registered, "original token already wrapped"); //###// change err msg

            originalToken.registered = true;
            originalToken.chainId = _originalTokenChainId;
            originalToken.addr = _originalTokenAddr;
        }

        otherChainTokensToWrappedTokens_[_fromChainTokenAddr][_fromChainId] = wrappedTokenAddr;

        emit TeleportPairCreated(
            _fromChainId,
            _fromChainTokenAddr,
            _fromChainRegisterTxHash,
            _originalTokenAddr,
            _originalTokenChainId,
            wrappedTokenAddr,
            _name,
            _symbol,
            _decimals);

        return wrappedTokenAddr;
    }

    function teleportStart(address _tokenAddr, uint256 _amount, uint256 _toChainId) payable external returns (bool) {
        address msgSender = _msgSender();

        _ensureNotContract(msgSender);

        require(msg.value >= teleportFee_, ERROR_FEE_MISMATCH);

        if (msg.value != 0) {
            payable(owner()).transfer(msg.value);
        }

        uint256 originalTokenChainId;
        address originalTokenAddr;

        if (originalTokens_[_tokenAddr]) {
            require(routesFromTokenToChain_[_tokenAddr][_toChainId], ERROR_TELEPORT_PAIR_NOT_CREATED);

            IERC20(_tokenAddr).safeTransferFrom(msgSender, address(this), _amount);

            originalTokenChainId = block.chainid;
            originalTokenAddr = _tokenAddr;
        } else {
            OriginalToken storage originalToken = wrappedToOriginalTokens_[_tokenAddr];

            require(originalToken.registered, "token address not wrapped");

            IWrappedToken(_tokenAddr).burn(msgSender, _amount);

            originalTokenChainId = originalToken.chainId;
            originalTokenAddr = originalToken.addr;

            if (_toChainId == originalTokenChainId) {
                require(originalToWrappedTokens_[_toChainId][originalTokenAddr] == _tokenAddr, ERROR_TELEPORT_PAIR_NOT_CREATED);
            } else {
                require(routesFromTokenToChain_[_tokenAddr][_toChainId], ERROR_TELEPORT_PAIR_NOT_CREATED);
            }
        }

        emit TeleportStarted(msgSender, originalTokenChainId, originalTokenAddr, _tokenAddr, _amount, _toChainId, msg.value);

        return true;
    }

    function teleportFinish(
        uint256 _fromChainId,
        address _fromChainTokenAddr,
        bytes32 _fromChainStartTxHash,
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        address _toAddress,
        uint256 _amount) onlyOwner external returns (bool) {

        require(!filledTeleports_[_fromChainStartTxHash], ERROR_TELEPORT_TX_FILLED_ALREADY);
        filledTeleports_[_fromChainStartTxHash] = true;

        if (block.chainid == _originalTokenChainId && originalTokens_[_originalTokenAddr]) {
            IERC20(_originalTokenAddr).safeTransfer(_toAddress, _amount);
        } else {
            address wrappedTokenAddr = otherChainTokensToWrappedTokens_[_fromChainTokenAddr][_fromChainId];
            require(wrappedTokenAddr != address(0x0), ERROR_TELEPORT_PAIR_NOT_CREATED);

            IWrappedToken(wrappedTokenAddr).mintTo(_toAddress, _amount);
        }

        emit TeleportFinished(
            _fromChainId,
            _fromChainTokenAddr,
            _fromChainStartTxHash,
            _originalTokenChainId,
            _originalTokenAddr,
            _toAddress,
            _amount);

        return true;
    }

    function _deployMinimalProxy(address _logic) private returns (address proxy) {
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(_logic);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }
}