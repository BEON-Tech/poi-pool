// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MockUpgradeableToken is Initializable, ERC20Upgradeable {
    function initialize() public initializer {
        __ERC20_init("MockUpgradeableToken", "MKUT");
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}