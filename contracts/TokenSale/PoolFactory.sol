// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
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

                // solhint-disable-next-line no-inline-assembly
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

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    modifier initializer() {
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: contract is already initialized"
        );

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

interface IERC20Upgradeable {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data)
        private
    {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPool {
    function initialize(
        address[4] memory _addrs, // [0] = token, [1] = router, [2] = governance , [3] = Authority
        uint256 [16] memory _saleInfo, 
        string memory _poolDetails,
        address[4] memory _linkAddress, // [0] factory ,[1] = manager 
        uint8 _version,
        uint256 _contributeWithdrawFee,
        string[3] memory _otherInfo,
        uint256 baseBonusRate_
    ) external;

    function initializeVesting(uint256[3] memory _vestingInit) external;

    function setKycAudit(bool _kyc , bool _audit , string memory _kyclink,string memory _auditlink) external;

    function emergencyWithdrawLiquidity(
        address token_,
        address to_,
        uint256 amount_
    ) external;

    function emergencyWithdraw(address payable to_, uint256 amount_) external;

    function setGovernance(address governance_) external;

    function emergencyWithdrawToken(
        address payaddress,
        address tokenAddress,
        uint256 tokens
    ) external;
}

interface IPoolManager {
    function registerPool(
        address pool,
        address token,
        address owner,
        uint8 version
    ) external;

    function addPoolFactory(address factory) external;

    function payAmaPartner(
        address[] memory _partnerAddress,
        address _poolAddress
    ) external payable;

    function poolForToken(address token) external view returns (address);
    function isPoolGenerated(address pool) external view returns (bool);
    
}

library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000
            )
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

interface ITokenFactory {
    function IsCreatedTokenByFactory(address _token) external view returns(bool);
}

contract PoolFactory is OwnableUpgradeable {
    address public master;
    address public elevAddress;
    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address public poolOwner;
    address public poolManager;
    address public tokenFactory;
    uint8 public version;
    uint256 public kycPrice;
    uint256 public auditPrice;
    uint256 public masterPrice;
    bool public IsEnabled;
    uint256 public contributeWithdrawFee; //1% ~ 100
    using Clones for address;
    address payable public adminWallet;
    uint256 public partnerFee;
    uint256 public MIN_LOCK_DAYS;
    uint256 public MIN_RAISE_ETH;
    uint256 public BONUS_RATE_PER_TIER;

    mapping(address => bool) public isCreatedByOwner;
    

    function initialize(
        address _master,
        address _elevAddr,
        address _poolmanager,
        uint8 _version,
        uint256 _kycPrice,
        uint256 _auditPrice,
        uint256 _masterPrice,
        uint256 _contributeWithdrawFee,
        bool _IsEnabled
    ) external initializer {
        __Ownable_init();
        master = _master;
        elevAddress = _elevAddr;
        poolManager = _poolmanager;
        kycPrice = _kycPrice;
        auditPrice = _auditPrice;
        masterPrice = _masterPrice;
        contributeWithdrawFee = _contributeWithdrawFee;
        version = _version;
        IsEnabled = _IsEnabled;
        MIN_LOCK_DAYS = 30 days;
        MIN_RAISE_ETH = 30 ether;
        BONUS_RATE_PER_TIER = 2000;
    }

    receive() external payable {}

    function setMasterAddress(address _address) public onlyOwner {
        require(_address != address(0), "master must be set");
        master = _address;
    }

    function setELEV(address _address) external onlyOwner {
        require(_address != address(0), "elev must be set");
        elevAddress = _address;
    }

    function setAdminWallet(address payable _address) public onlyOwner {
        require(_address != address(0), "master must be set");
        adminWallet = _address;
    }

    function setPartnerFee(uint256 _partnerFees) public onlyOwner{
        partnerFee = _partnerFees;
    }

    function setVersion(uint8 _version) public onlyOwner {
        version = _version;
    }

    function setcontributeWithdrawFee(uint256 _fees) public onlyOwner {
        contributeWithdrawFee = _fees;
    }

    function setTokenFactory(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "tokenFactory must be set");
        tokenFactory = _newAddress;
    }

    modifier _checkTokeneEligible(address _currencyaddress , address _tokenaddress , address _router) {
        address ethAddress = IUniswapV2Router01(_router).WETH();
        address factoryAddress = IUniswapV2Router01(_router).factory();
        address getPair = IUniswapV2Factory(factoryAddress).getPair(
            _currencyaddress == address(0) ? ethAddress : _currencyaddress,
            _tokenaddress
        );
        if(getPair != address(0)){
           uint256 Lpsupply = IERC20Upgradeable(getPair).totalSupply();
           require(Lpsupply == 0 , "Already Pair Exist in router, token not eligible for sale");
        }
        _;
  }

    function initalizeClone(
        address _pair,
        address[4] memory _addrs, 
        uint256[16] memory _saleInfo,
        string memory _poolDetails,
        uint256[3] memory _vestingInit,
        string[3] memory _otherInfo
    ) internal _checkTokeneEligible(_addrs[3], _addrs[0],_addrs[1]) {
        
        IPool(_pair).initialize(
            _addrs,
            _saleInfo,
            _poolDetails,
            [poolOwner, poolManager , adminWallet, elevAddress],
            version,
            contributeWithdrawFee,
            _otherInfo,
            BONUS_RATE_PER_TIER
        );

        IPool(_pair).initializeVesting(_vestingInit);
        
        address poolForToken = IPoolManager(poolManager).poolForToken(
            _addrs[0]
        );
        require(poolForToken == address(0), "Pool Already Exist!!");
    
    }

    function createSale(
        address[4] memory _addrs, 
        uint256[16] memory _saleInfo,
        string memory _poolDetails,
        uint256[3] memory _vestingInit,
        string[3] memory _otherInfo
    ) external payable {
        require(
            IsEnabled,
            "Create sale currently on hold , try again after sometime!!"
        );
        require(master != address(0), "pool address is not set!!");
        require(tokenFactory != address(0), "TokenFactory address is not set!!");
        if(msg.sender != owner()) {
            require(
                ITokenFactory(tokenFactory).IsCreatedTokenByFactory(_addrs[0]),
                "This token wasn't created by Factory"
            );
        }
        require(_saleInfo[5] >= MIN_RAISE_ETH, "Invalid Hardcap amount");
        require(_saleInfo[8] >= MIN_LOCK_DAYS, "Invalid lock period");
        checkfees(_saleInfo[10], _saleInfo[11]);
        //fees transfer to Admin wallet
        (bool success, ) = adminWallet.call{ value: msg.value }("");
        require(success, "Address: unable to send value, recipient may have reverted");

        bytes32 salt = keccak256(
            abi.encodePacked(_poolDetails, block.timestamp)
        );
        address pair = Clones.cloneDeterministic(master, salt);
        //Clone Contract
        initalizeClone(
            pair,
            _addrs,
            _saleInfo,
            _poolDetails,
            _vestingInit,
            _otherInfo
        );
        uint256 totalToken = _feesCount(
            _saleInfo[0],
            _saleInfo[1],
            _saleInfo[5],
            _saleInfo[14],
            _saleInfo[12]
        );
        _safeTransferFromEnsureExactAmount(
            _addrs[0],
            address(msg.sender),
            address(this),
            totalToken
        );
        _transferFromEnsureExactAmount(_addrs[0], pair, totalToken);
        IPoolManager(poolManager).addPoolFactory(pair);
        IPoolManager(poolManager).registerPool(
            pair,
            _addrs[0],
            _addrs[2],
            version
        );
        if (msg.sender == owner()) {
            isCreatedByOwner[pair] = true;
        }
    }

    function _safeTransferFromEnsureExactAmount(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 oldRecipientBalance = IERC20Upgradeable(token).balanceOf(
            recipient
        );
        IERC20Upgradeable(token).safeTransferFrom(sender, recipient, amount);
        uint256 newRecipientBalance = IERC20Upgradeable(token).balanceOf(
            recipient
        );
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "Not enough token was transfered If tax set Remove Our Address!!"
        );
    }

    function _transferFromEnsureExactAmount(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        uint256 oldRecipientBalance = IERC20Upgradeable(token).balanceOf(
            recipient
        );
        IERC20Upgradeable(token).transfer(recipient, amount);
        uint256 newRecipientBalance = IERC20Upgradeable(token).balanceOf(
            recipient
        );
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "Not enough token was transfered If tax set Remove Our Address!!"
        );
    }

    function checkfees(
        uint256 _audit,
        uint256 _kyc
    ) internal {
        uint256 totalFees = 0;
        totalFees += masterPrice;
        
        if (_audit == 1) {
            totalFees += auditPrice;
        }

        if (_kyc == 1) {
            totalFees += kycPrice;
        }

        require(
            msg.value >= totalFees,
            "Payble Amount is less than required !!"
        );
    }

    function _feesCount(
        uint256 _rate,
        uint256 _Lrate,
        uint256 _hardcap,
        uint256 _liquidityPercent,
        uint256 _fees
    ) internal pure returns (uint256) {
        uint256 totalToken = (((_rate * _hardcap) / 10**18)).add(
            (((_hardcap * _Lrate) / 10**18) * _liquidityPercent) / 100
        );
        uint256 totalFees = (((((_rate * _hardcap) / 10**18)) * _fees) / 100);
        uint256 total = totalToken.add(totalFees);
        return total;
    }

    function setPoolOwner(address _address) public onlyOwner {
        require(_address != address(0), "Invalid Address found");
        poolOwner = _address;
    }

    function setKycPrice(uint256 _price) public onlyOwner {
        kycPrice = _price;
    }

    function setAuditPrice(uint256 _price) public onlyOwner {
        auditPrice = _price;
    }

    function setPresalePoolPrice(uint256 _price) public onlyOwner {
        masterPrice = _price;
    }

    function setPoolManager(address _address) public onlyOwner {
        require(_address != address(0), "Invalid Address found");
        poolManager = _address;
    }

    function ethLiquidity(address payable _reciever, uint256 _amount)
        public
        onlyOwner
    {
        _reciever.transfer(_amount);
    }

    function transferAnyERC20Token(
        address payaddress,
        address tokenAddress,
        uint256 tokens
    ) public onlyOwner {
        IERC20Upgradeable(tokenAddress).transfer(payaddress, tokens);
    }

    function updateKycAuditStatus(
        address _poolAddress,
        bool _kyc,
        bool _audit,
        string memory _kyclink,
        string memory _auditlink
    ) public onlyOwner {
        require(
            IPoolManager(poolManager).isPoolGenerated(_poolAddress),
            "Pool Not exist !!"
        );
        IPool(_poolAddress).setKycAudit(_kyc, _audit , _kyclink , _auditlink );
    }

    function poolEmergencyWithdrawLiquidity(
        address poolAddress,
        address token_,
        address to_,
        uint256 amount_
    ) public onlyOwner {
        IPool(poolAddress).emergencyWithdrawLiquidity(token_, to_, amount_);
    }

    function poolEmergencyWithdrawToken(
        address poolAddress,
        address payaddress,
        address tokenAddress,
        uint256 tokens
    ) public onlyOwner {
        IPool(poolAddress).emergencyWithdrawToken(
            payaddress,
            tokenAddress,
            tokens
        );
    }

    function poolEmergencyWithdraw(
        address poolAddress,
        address payable to_,
        uint256 amount_
    ) public onlyOwner {
        IPool(poolAddress).emergencyWithdraw(to_, amount_);
    }

    function poolSetGovernance(address poolAddress, address _governance)
        public
        onlyOwner
    {
        IPool(poolAddress).setGovernance(_governance);
    }

    function setPoolMinLockDay(uint256 newDays) external onlyOwner {
        MIN_LOCK_DAYS = newDays;
    }

    function setPoolMinRaiseETH(uint256 newValue) external onlyOwner {
        MIN_RAISE_ETH = newValue;
    }

    function setBonusBasePerTier(uint256 newValue) external onlyOwner {
        BONUS_RATE_PER_TIER = newValue;
    }
}
