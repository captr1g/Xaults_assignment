// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import {AssetToken} from "../src/AssetToken.sol";
import {AssetTokenV2} from "../src/AssetTokenV2.sol";
import {
    ERC1967Proxy
} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {
    PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {
    Initializable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract AssetTokenTest is Test {
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    AssetToken public token;
    ERC1967Proxy public proxy;

    address public admin = address(this);
    address public user = address(0x1);
    address public other = address(0x2);
    uint256 public constant MAX_SUPPLY = 1_000_000 * 1e18;

    function setUp() public {
        // 1. Setup: Deploy V1 via ERC1967Proxy
        AssetToken implementation = new AssetToken();

        // Encode initialization call
        bytes memory initData = abi.encodeCall(
            AssetToken.initialize,
            (MAX_SUPPLY)
        );

        // Deploy Proxy
        proxy = new ERC1967Proxy(address(implementation), initData);

        // Wrap proxy address in V1 interface
        token = AssetToken(address(proxy));
    }

    function test_Initialization() public view {
        assertEq(token.maxSupply(), MAX_SUPPLY);
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(token.hasRole(token.MINTER_ROLE(), admin));
    }

    function test_Minting() public {
        // 2. State Check: Mint 100 tokens
        uint256 mintAmount = 100 * 1e18;
        token.mint(user, mintAmount);

        assertEq(token.balanceOf(user), mintAmount);
    }

    function test_MintingCap() public {
        // Try to mint more than max supply
        vm.expectRevert(AssetToken.MaxSupplyExceeded.selector);
        token.mint(user, MAX_SUPPLY + 1);
    }

    function test_AccessControl() public {
        // Try to mint as non-minter
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 100);
    }

    function test_UpgradeLifecycle() public {
        // Setup initial state
        uint256 mintAmount = 100 * 1e18;
        token.mint(user, mintAmount);

        // 3. Upgrade: Deploy V2
        AssetTokenV2 implementationV2 = new AssetTokenV2();

        // Execute upgrade on proxy and call initializeV2
        token.upgradeToAndCall(
            address(implementationV2),
            abi.encodeCall(AssetTokenV2.initializeV2, ())
        );

        // 4. Persistence Check
        assertEq(
            token.balanceOf(user),
            mintAmount,
            "User balance should persist after upgrade"
        );
        assertEq(token.maxSupply(), MAX_SUPPLY, "Max supply should persist");

        // 5. New Logic Check
        AssetTokenV2 tokenV2 = AssetTokenV2(address(proxy));

        // Test Pause functionality
        tokenV2.pause();
        assertTrue(tokenV2.paused());

        // Transfers should revert when paused
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        vm.prank(user);
        (bool successRevert) = tokenV2.transfer(other, 10 * 1e18);
        successRevert; // Silence unused variable warning

        // Unpause and verify transfer works
        tokenV2.unpause();
        vm.prank(user);
        bool success = tokenV2.transfer(other, 10 * 1e18);
        assertTrue(success);
        assertEq(tokenV2.balanceOf(other), 10 * 1e18);
    }

    function test_RevertIf_UnauthorizedUpgrade() public {
        // Upgrade: Deploy V2
        AssetTokenV2 implementationV2 = new AssetTokenV2();

        // Expect revert when user tries to upgrade
        vm.prank(user);
        vm.expectRevert();
        token.upgradeToAndCall(
            address(implementationV2),
            abi.encodeCall(AssetTokenV2.initializeV2, ())
        );
    }

    function test_RevertIf_UnauthorizedPause() public {
        // Upgrade to V2
        AssetTokenV2 implementationV2 = new AssetTokenV2();
        token.upgradeToAndCall(
            address(implementationV2),
            abi.encodeCall(AssetTokenV2.initializeV2, ())
        );
        AssetTokenV2 tokenV2 = AssetTokenV2(address(proxy));

        // Expect revert for pause
        vm.prank(user);
        vm.expectRevert();
        tokenV2.pause();

        // Expect revert for unpause
        vm.prank(user);
        vm.expectRevert();
        tokenV2.unpause();
    }

    function test_RevertIf_MintWhilePaused() public {
        // Upgrade to V2
        AssetTokenV2 implementationV2 = new AssetTokenV2();
        token.upgradeToAndCall(
            address(implementationV2),
            abi.encodeCall(AssetTokenV2.initializeV2, ())
        );
        AssetTokenV2 tokenV2 = AssetTokenV2(address(proxy));

        // Pause
        tokenV2.pause();

        // Attempt mint
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        token.mint(user, 100);
    }

    function test_RevertIf_Reinitialization() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        token.initialize(MAX_SUPPLY);
    }

    function test_RevertIf_Overflow() public {
        // Mint explicit small amount to make sure totalSupply > 0
        token.mint(address(this), 1);

        // Attempt to mint type(uint256).max.
        vm.expectRevert(stdError.arithmeticError);
        token.mint(user, type(uint256).max);
    }
}
