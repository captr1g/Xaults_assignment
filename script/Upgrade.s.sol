// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AssetToken} from "../src/AssetToken.sol";
import {AssetTokenV2} from "../src/AssetTokenV2.sol";

contract UpgradeAssetToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy V2 Implementation
        AssetTokenV2 implementationV2 = new AssetTokenV2();
        console.log(
            "AssetTokenV2 Implementation deployed at:",
            address(implementationV2)
        );

        // Upgrade Proxy to V2 and Call initializeV2
        AssetToken(proxyAddress).upgradeToAndCall(
            address(implementationV2),
            abi.encodeCall(AssetTokenV2.initializeV2, ())
        );

        vm.stopBroadcast();
        console.log("Upgraded Proxy at:", proxyAddress);
    }
}
