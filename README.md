# Upgradeable Asset Tokenizer

This project implements a UUPS upgradeable ERC20 token with access control and a capped supply. It demonstrates a safe upgrade path to a V2 implementation that adds pausable functionality.

## Setup

1. Install dependencies:
   ```bash
   forge install OpenZeppelin/openzeppelin-contracts-upgradeable OpenZeppelin/openzeppelin-contracts --no-commit
   ```
2. Build the project:
   ```bash
   forge build
   ```

## Testing

Run the test suite to verify the upgrade lifecycle and storage persistence:
```bash
forge test -vv
```

## Deployment

To deploy to a local testnet (e.g., Anvil):

1. Start Anvil:
   ```bash
   anvil
   ```
2. Run the script:
   ```bash
   forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key <PRIVATE_KEY_FROM_ANVIL>
   ```

## CLI Interaction

Example of manually interacting with the deployed contract using `cast`:

```bash
# Mint 100 tokens to a specific address (assuming you are the admin/minter)
cast send <PROXY_ADDRESS> "mint(address,uint256)" <RECEIVER_ADDRESS> 100000000000000000000 --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY>
```

## Storage Safety Verification

Storage safety is ensured by:
1. **Inheritance**: `AssetTokenV2` inherits from `AssetToken`, ensuring the base storage layout (variables like `maxSupply`) remains at the same slots.
2. **Namespaced Storage**: We utilize OpenZeppelin v5.x contracts. These contracts use ERC-7201 Namespaced Storage for upgradeable mixins (like `PausableUpgradeable`). This prevents storage collisions between the inheritance chain and new mixins added in V2.