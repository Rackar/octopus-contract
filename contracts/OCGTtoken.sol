pragma solidity ^0.8.3;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OCGTtoken is ERC20 {
    constructor() ERC20("OctopusGameToken", "OCGT") {
        _mint(msg.sender, 1000000 * (10**uint256(decimals())));
    }
}
