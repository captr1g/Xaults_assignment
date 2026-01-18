# Upgradeable Asset Tokenizer

This project implements a UUPS upgradeable ERC20 token with access control and a capped supply. It demonstrates a safe upgrade path to a V2 implementation that adds pausable functionality.

## Sepolia Testnet Deployment

| Contract | Address |
| :--- | :--- |
| **Proxy (AssetToken)** | [`0xD48671D86121d9A15a0f3D661362617D2eeb83E1`](https://sepolia.etherscan.io/address/0xD48671D86121d9A15a0f3D661362617D2eeb83E1) |
| **AssetTokenV1 Implementation** | [`0xF49c4a6271398a9a8283292BD21623dC955ed4ff`](https://sepolia.etherscan.io/address/0xF49c4a6271398a9a8283292BD21623dC955ed4ff) |
| **AssetTokenV2 Implementation** | [`0xBeF8024A88732b3195940785e1b07aBd6b901740`](https://sepolia.etherscan.io/address/0xBeF8024A88732b3195940785e1b07aBd6b901740) |

## Setup

1. **Install Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Install Dependencies**:
   ```bash
   forge install
   ```

3. **Configure Environment**:
   Create a `.env` file from the template:
   ```bash
   cp .env.example .env # (If example exists, otherwise create new)
   ```
   Populate it with your keys:
   ```ini
   PRIVATE_KEY=0x...
   SEPOLIA_RPC_URL=https://...
   ETHERSCAN_API_KEY=...
   PROXY_ADDRESS=0xD48671D86121d9A15a0f3D661362617D2eeb83E1
   ```

## Usage

### 1. Build and Test
```bash
forge build
forge test -vv
```

### 2. Deploy (fresh)
```bash
source .env
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### 3. Upgrade to V2
```bash
source .env
forge script script/Upgrade.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### 4. Mint Tokens
```bash
source .env
forge script script/Mint.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

## Security & Architecture

### Storage Safety
- **Inheritance**: `AssetTokenV2` inherits `AssetToken` to preserve storage slots.
- **Namespaced Storage**: Uses OpenZeppelin v5.0 Namespaced Storage for upgradeable mixins to prevent collisions.

### Verification
- **Slither**: Static analysis (recommended).
- **Foundry Tests**: Includes unit tests for upgrades, access control, and pause logic.