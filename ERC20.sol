//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <=0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RCTtoken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 100000 * (10 ** 18));
    }
}