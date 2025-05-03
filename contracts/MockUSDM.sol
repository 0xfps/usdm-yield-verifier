// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDM is ERC20 {
    constructor() ERC20("Mock USDm", "USDM") {
        _mint(msg.sender, 1000000 * 1e18); // 1M tokens to deployer
    }
}

