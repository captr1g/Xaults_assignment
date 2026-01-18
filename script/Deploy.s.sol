// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AssetToken} from "../src/AssetToken.sol";
import {
    ERC1967Proxy
} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployAssetToken is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Implementation
        AssetToken implementation = new AssetToken();

        // Prepare Initialization Data (1M Max Supply)
        bytes memory initData = abi.encodeCall(
            AssetToken.initialize,
            (1_000_000 * 1e18)
        );

        // Deploy Proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        console.log("AssetToken Proxy deployed at:", address(proxy));
        return address(proxy);
    }
}
