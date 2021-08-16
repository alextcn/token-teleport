// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20TokenImplementation.sol";

// mock class using ERC20TokenImplementation
contract ERC20Mock is ERC20TokenImplementation {
    
    function transferInternal(
        address from,
        address to,
        uint256 value
    ) public {
        _transfer(from, to, value);
    }

    function approveInternal(
        address owner,
        address spender,
        uint256 value
    ) public {
        _approve(owner, spender, value);
    }
}
