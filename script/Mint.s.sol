// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AssetToken} from "../src/AssetToken.sol";

contract MintAssetToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");

        // Target address and amount
        address to = 0x5548b799EFA78555bb64c6D2497d59bE8cc63eaB;
        uint256 amount = 100 * 1e18;

        vm.startBroadcast(deployerPrivateKey);

        AssetToken(proxyAddress).mint(to, amount);

        vm.stopBroadcast();

        console.log("Minted", amount, "tokens to", to);
    }
}
