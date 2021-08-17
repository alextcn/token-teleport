// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "../ERC20TokenImplementation.sol";

contract OwnableMock is Ownable {
    constructor() {
        initializeOwnable(msg.sender);
    }
}
