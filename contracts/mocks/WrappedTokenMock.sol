// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IWrappedToken {
    function initialize(string calldata name, string calldata symbol, uint8 decimals, address owner) external;
    function mintTo(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint256 amount) external returns (bool);
}

contract WrappedTokenMock is IWrappedToken {
    event Initialized(string name, string symbol, uint8 decimals, address owner);
    event MintTo(address recipient, uint256 amount);
    event Burn(address account, uint256 amount);

    function initialize(string calldata name, string calldata symbol, uint8 decimals, address owner) {
        emit Initialized(name, symbol, decimals, owner);
    }

    function mintTo(address recipient, uint256 amount) external returns (bool) {
        emit MintTo(recipient, amount);
        return true;
    }

    function burn(address account, uint256 amount) external returns (bool) {
        emit Burn(account, amount);
        return true;
    }
}
