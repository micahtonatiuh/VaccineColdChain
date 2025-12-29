# VaccineColdChain - Hybrid Blockchain Architecture

[![Tests](https://github.com/YOUR_USERNAME/VaccineColdChain/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/VaccineColdChain/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/YOUR_USERNAME/VaccineColdChain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

Hybrid blockchain system for vaccine cold chain traceability combining:
- **Hyperledger Fabric** (private, high-frequency IoT data)
- **Base L2** (public verification via Merkle proofs)

## Architecture
```
IoT Sensors → Fabric Network → Python Script → CustodyAnchor (L2)
                (Private)         Batch          (Public Verify)
```

## Deployed Contracts

| Network       | Address                                      | Explorer                                |
|---------------|----------------------------------------------|-----------------------------------------|
| Base Sepolia  | `0xAb3D18543f78c1e205aaAf55605A4279d5DF7c43` | [View](https://sepolia.basescan.org/address/0xAb3D18543f78c1e205aaAf55605A4279d5DF7c43) |

## Quick Start
```bash
# Install dependencies
forge install

# Run tests
forge test

# Deploy to testnet
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://sepolia.base.org \
  --broadcast
```

## Test Coverage
```
Lines:      100.00% (23/23)
Statements: 100.00% (20/20)
Branches:   100.00% (4/4)
Functions:  100.00% (7/7)
```

## Key Features

- ✅ 100% test coverage
- ✅ Fuzzing tests included
- ✅ OpenZeppelin security standards
- ✅ Gas-optimized (161k avg per batch anchor)
- ✅ Event-driven architecture
- ✅ Merkle proof verification

## Development

Built with:
- Foundry (Solidity development framework)
- OpenZeppelin Contracts
- Base L2 (Ethereum Layer 2)

## License

MIT
