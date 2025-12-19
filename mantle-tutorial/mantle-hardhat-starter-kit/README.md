# 🏠 Real Estate Rent Stream Tokenization Platform

**A DeFi protocol for tokenizing real estate rental income with dynamic risk tranching on Mantle Network**

## 🎯 Hackathon Project Overview

This project implements a complete Real World Asset (RWA) tokenization system that:
- Tokenizes real estate rental income streams
- Implements dynamic risk tranching (Senior/Junior)
- Uses oracle-based property data for risk assessment
- Provides automated yield distribution based on occupancy rates
- Built on Mantle Network for low-cost, high-performance transactions

## 📋 Key Features

### 1. **Oracle Adapter**
- Real-time property data integration
- Occupancy rate tracking
- Rental income monitoring
- Risk score calculation

### 2. **Tranche Vault System**
- **Senior Tranche**: Lower risk, stable yields (5-7%)
- **Junior Tranche**: Higher risk, higher yields (10-15%)
- Dynamic rebalancing based on property performance
- Automated yield distribution

### 3. **Token Management**
- ERC20-compliant tranche tokens
- Automated minting/burning
- Proportional yield distribution

### 4. **Factory Pattern**
- Deploy multiple vaults for different properties
- Standardized vault creation
- Efficient resource management via proxy clones

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   TrancheFactory                         │
│  (Creates new vaults for each property)                  │
└─────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────┐
│                    TrancheVault                          │
│  Property: NYC_APT_001                                   │
│  ┌─────────────────┐    ┌─────────────────┐            │
│  │ Senior Tranche  │    │ Junior Tranche  │            │
│  │   70% of TVL    │    │   30% of TVL    │            │
│  │   5% target     │    │   10% target    │            │
│  └─────────────────┘    └─────────────────┘            │
└─────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  OracleAdapter                           │
│  - Occupancy: 92%                                        │
│  - Rental Income: $5,000/month                           │
│  - Risk Score: 480                                       │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
```bash
node >= 18.0.0
npm >= 9.0.0
```

### Installation & Compilation (COMPLETED ✅)

```bash
# Navigate to project directory
cd mantle-tutorial/mantle-hardhat-starter-kit

# Dependencies installed ✅
# Contracts compiled ✅
# Tests passing: 14/14 ✅
```

### Configuration

1. Create/update `.env` file:
```env
# Your deployment private key
PRIVATE_KEY=your_private_key_here

# Network RPCs (defaults provided)
# MANTLE_TESTNET_RPC=https://rpc.testnet.mantle.xyz
# MANTLE_MAINNET_RPC=https://rpc.mantle.xyz
```

2. Get testnet MNT:
   - Visit: https://faucet.testnet.mantle.xyz
   - Get free testnet tokens for deployment

### Deployment

```bash
# Deploy to Mantle Testnet
npm run deploy:testnet

# Deploy to Mantle Mainnet
npm run deploy:mainnet
```

### Create a Demo Vault

After deployment, update `scripts/createDemoVault.js` with your factory address, then:

```bash
npm run create-vault
```

### Verify Contracts

```bash
# Verify on Mantle Testnet
npx hardhat verify --network mantleTestnet <CONTRACT_ADDRESS>
```

## 📊 Smart Contracts

### OracleAdapter.sol
Manages property data and risk calculations
- Updates occupancy rates
- Tracks rental income
- Calculates risk scores
- Authorizes oracle feeds

### TrancheFactory.sol
Factory pattern for vault deployment
- Creates new vaults via clones
- Validates tranche ratios
- Tracks all deployed vaults

### TrancheVault.sol
Core vault logic for each property
- Manages deposits (Senior/Junior)
- Distributes yields
- Dynamic rebalancing
- Risk-adjusted returns

### SeniorToken.sol / JuniorToken.sol
ERC20 tokens representing tranches
- Mintable by vault only
- Burnable by vault only
- Transferable

## 🧪 Testing

All contracts have comprehensive test coverage:

```bash
# Run all tests
npx hardhat test
```

**Test Results: ✅ ALL PASSING**
```
✔ 14 passing tests
✔ OracleAdapter: 4/4 tests passed
✔ TrancheFactory: 4/4 tests passed
✔ TrancheVault: 6/6 tests passed
```

## 📱 Frontend Integration

Basic frontend structure created in `/frontend`:

```bash
cd frontend
npm install
npm run dev
```

## 💡 Use Cases

### For Property Owners
- Tokenize rental income streams
- Access immediate liquidity
- Maintain property ownership
- Lower capital costs

### For Investors

**Senior Tranche Investors:**
- Conservative investors
- Seeking stable 5-7% yields
- Priority in yield distribution
- Lower risk tolerance

**Junior Tranche Investors:**
- Risk-seeking investors
- Targeting 10-15% yields
- Higher risk tolerance
- First-loss capital protection

## 🔧 Development

### Project Structure
```
mantle-hardhat-starter-kit/
├── contracts/
│   ├── OracleAdapter.sol
│   ├── TrancheFactory.sol
│   ├── tokens/
│   │   ├── SeniorToken.sol
│   │   └── JuniorToken.sol
│   └── vaults/
│       └── TrancheVault.sol
├── scripts/
│   ├── deploy.js
│   └── createDemoVault.js
├── test/
│   └── RealEstateTokenization.test.js
├── frontend/
│   └── package.json
└── hardhat.config.js
```

## 🌐 Networks

### Mantle Testnet
- Chain ID: 5003
- RPC: https://rpc.testnet.mantle.xyz
- Explorer: https://explorer.testnet.mantle.xyz
- Faucet: https://faucet.testnet.mantle.xyz

### Mantle Mainnet
- Chain ID: 5000
- RPC: https://rpc.mantle.xyz
- Explorer: https://explorer.mantle.xyz

## 🎯 Next Steps

1. **Add your private key** to `.env`: `PRIVATE_KEY=your_key_here`
2. **Get testnet MNT** from Mantle faucet
3. **Deploy**: `npm run deploy:testnet`
4. **Verify**: `npx hardhat verify --network mantleTestnet <ADDRESS>`
5. **Test**: `npx hardhat test`

## 🔒 Security

- OpenZeppelin contracts for battle-tested implementations
- ReentrancyGuard on critical functions
- Access control via Ownable
- Comprehensive test coverage

## 📜 License

MIT License

## 🏆 Hackathon Submission

**Built for:** Mantle Network Hackathon
**Category:** DeFi / RWA
**Status:** Ready for Deployment ✅

---

**Made with ❤️ for Mantle Network**
