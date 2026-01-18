// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AssetToken is Initializable, ERC20Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public maxSupply;

    error MaxSupplyExceeded();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 _maxSupply) public initializer {
        __ERC20_init("AssetToken", "AST");
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        maxSupply = _maxSupply;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        if (totalSupply() + amount > maxSupply) {
            revert MaxSupplyExceeded();
        }
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}