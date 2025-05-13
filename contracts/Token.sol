// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {console} from "hardhat/console.sol";

contract Token is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint initialMinValue
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialMinValue * 10 ** decimals());
    }
}
