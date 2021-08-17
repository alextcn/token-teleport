// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "../BscTeleportAgent.sol";

/**
 * @title InitializableMock
 * @dev This contract is a mock to test initializable functionality
 */
contract InitializableMock is Initializable {
    bool public initializerRan;
    uint256 public x;

    function initialize() public initializer {
        initializerRan = true;
    }

    function initializeNested() public initializer {
        initialize();
    }

    function initializeWithX(uint256 _x) public payable initializer {
        x = _x;
    }

    function nonInitializable(uint256 _x) public payable {
        x = _x;
    }

    function fail() public pure {
        require(false, "InitializableMock forced failure");
    }
}

contract ContextMock is Context {
    event Sender(address sender);

    function msgSender() public {
        emit Sender(_msgSender());
    }

    event Data(bytes data, uint256 integerValue, string stringValue);

    function msgData(uint256 integerValue, string memory stringValue) public {
        emit Data(_msgData(), integerValue, stringValue);
    }
}

contract ContextMockCaller {
    function callSender(ContextMock context) public {
        context.msgSender();
    }

    function callData(
        ContextMock context,
        uint256 integerValue,
        string memory stringValue
    ) public {
        context.msgData(integerValue, stringValue);
    }
}

contract OwnableMock is Ownable {
    constructor() {
        initializeOwnable(msg.sender);
    }
}

contract AddressImpl {
    string public sharedAnswer;

    event CallReturnValue(string data);

    function isContract(address account) external view returns (bool) {
        return Address.isContract(account);
    }

//    function sendValue(address payable receiver, uint256 amount) external {
//        Address.sendValue(receiver, amount);
//    }

//    function functionCall(address target, bytes calldata data) external {
//        bytes memory returnData = Address.functionCall(target, data);
//        emit CallReturnValue(abi.decode(returnData, (string)));
//    }

    function functionCallWithValue(
        address target,
        bytes calldata data,
        uint256 value
    ) external payable {
        bytes memory returnData = Address.functionCallWithValue(target, data, value, "functionCallWithValue-mock-failed");
        emit CallReturnValue(abi.decode(returnData, (string)));
    }

//    function functionStaticCall(address target, bytes calldata data) external {
//        bytes memory returnData = Address.functionStaticCall(target, data);
//        emit CallReturnValue(abi.decode(returnData, (string)));
//    }

//    function functionDelegateCall(address target, bytes calldata data) external {
//        bytes memory returnData = Address.functionDelegateCall(target, data);
//        emit CallReturnValue(abi.decode(returnData, (string)));
//    }

    // sendValue's tests require the contract to hold Ether
    receive() external payable {}
}


contract BEP20ReturnFalseMock is Context {
    uint256 private _allowance;

    // IERC20's functions are not pure, but these mock implementations are: to prevent Solidity from issuing warnings,
    // we write to a dummy state variable.
    uint256 private _dummy;

    function transfer(address, uint256) public returns (bool) {
        _dummy = 0;
        return false;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public returns (bool) {
        _dummy = 0;
        return false;
    }

    function approve(address, uint256) public returns (bool) {
        _dummy = 0;
        return false;
    }

    function allowance(address, address) public view returns (uint256) {
        require(_dummy == 0); // Duummy read from a state variable so that the function is view
        return 0;
    }
}

contract BEP20ReturnTrueMock is Context {
    mapping(address => uint256) private _allowances;

    // IERC20's functions are not pure, but these mock implementations are: to prevent Solidity from issuing warnings,
    // we write to a dummy state variable.
    uint256 private _dummy;

    function transfer(address, uint256) public returns (bool) {
        _dummy = 0;
        return true;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public returns (bool) {
        _dummy = 0;
        return true;
    }

    function approve(address, uint256) public returns (bool) {
        _dummy = 0;
        return true;
    }

    function setAllowance(uint256 allowance_) public {
        _allowances[_msgSender()] = allowance_;
    }

    function allowance(address owner, address) public view returns (uint256) {
        return _allowances[owner];
    }
}

contract BEP20NoReturnMock is Context {
    mapping(address => uint256) private _allowances;

    // IERC20's functions are not pure, but these mock implementations are: to prevent Solidity from issuing warnings,
    // we write to a dummy state variable.
    uint256 private _dummy;

    function transfer(address, uint256) public {
        _dummy = 0;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public {
        _dummy = 0;
    }

    function approve(address, uint256) public {
        _dummy = 0;
    }

    function setAllowance(uint256 allowance_) public {
        _allowances[_msgSender()] = allowance_;
    }

    function allowance(address owner, address) public view returns (uint256) {
        return _allowances[owner];
    }
}

contract SafeBEP20Wrapper is Context {
    using SafeBEP20 for IBEP20;

    IBEP20 private _token;

    constructor(IBEP20 token) {
        _token = token;
    }

    function transfer() public {
        _token.safeTransfer(address(0), 0);
    }

    function transferFrom() public {
        _token.safeTransferFrom(address(0), address(0), 0);
    }

//    function approve(uint256 amount) public {
//        _token.approve(address(0), amount);
//    }

//    function increaseAllowance(uint256 amount) public {
//        _token.increaseAllowance(address(0), amount);
//    }

//    function decreaseAllowance(uint256 amount) public {
//        _token.decreaseAllowance(address(0), amount);
//    }

    function setAllowance(uint256 allowance_) public {
        BEP20ReturnTrueMock(address(_token)).setAllowance(allowance_);
    }

    function allowance() public view returns (uint256) {
        return _token.allowance(address(0), address(0));
    }
}
