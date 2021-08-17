// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "../EthTeleportAgent.sol";

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

//    function functionCallWithValue(
//        address target,
//        bytes calldata data,
//        uint256 value
//    ) external payable {
//        bytes memory returnData = Address.functionCallWithValue(target, data, value);
//        emit CallReturnValue(abi.decode(returnData, (string)));
//    }

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
