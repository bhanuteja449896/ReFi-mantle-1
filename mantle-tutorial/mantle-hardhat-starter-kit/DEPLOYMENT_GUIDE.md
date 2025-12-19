# 🚀 Deployment Guide - Real Estate Tokenization Platform

## ✅ Project Setup Complete!

### What's Been Built

#### Smart Contracts (5 contracts)
1. **OracleAdapter.sol** - Property data oracle
2. **TrancheFactory.sol** - Vault factory with clone pattern  
3. **TrancheVault.sol** - Core vault logic
4. **SeniorToken.sol** - Senior tranche ERC20 token
5. **JuniorToken.sol** - Junior tranche ERC20 token

#### Deployment Scripts
1. **deploy.js** - Deploys OracleAdapter & TrancheFactory
2. **createDemoVault.js** - Creates demo property vault

#### Tests
- **RealEstateTokenization.test.js** - 14 comprehensive tests
- ✅ All tests passing

## 📋 Pre-Deployment Checklist

- [x] Contracts compiled successfully
- [x] All tests passing (14/14)
- [x] Hardhat configured for Mantle networks
- [ ] Private key added to .env
- [ ] Testnet MNT acquired
- [ ] Ready to deploy!

## 🔑 Step 1: Add Your Private Key

Edit `.env` file:
\`\`\`bash
# Uncomment and add your key
PRIVATE_KEY=your_actual_private_key_here
\`\`\`

**⚠️ NEVER commit .env file to git!**

## 💰 Step 2: Get Testnet Funds

1. Visit Mantle Testnet Faucet: https://faucet.testnet.mantle.xyz
2. Connect your wallet
3. Request testnet MNT tokens
4. Wait for confirmation

## 🚀 Step 3: Deploy Contracts

\`\`\`bash
# Deploy to Mantle Testnet
npm run deploy:testnet

# Expected output:
# 🚀 Deploying Real Estate Tokenization System on Mantle...
# 📊 Deploying OracleAdapter...
# ✅ OracleAdapter deployed to: 0x...
# 🏭 Deploying TrancheFactory...
# ✅ TrancheFactory deployed to: 0x...
# 📝 Setting up demo property data...
# 🎉 DEPLOYMENT COMPLETE!
\`\`\`

**Save the contract addresses!**

## 📝 Step 4: Verify Contracts

\`\`\`bash
# Verify OracleAdapter
npx hardhat verify --network mantleTestnet <ORACLE_ADAPTER_ADDRESS>

# Verify TrancheFactory
npx hardhat verify --network mantleTestnet <TRANCHE_FACTORY_ADDRESS> <ORACLE_ADAPTER_ADDRESS>
\`\`\`

## 🏗️ Step 5: Create Demo Vault

1. Update \`scripts/createDemoVault.js\`:
   - Replace \`REPLACE_WITH_FACTORY_ADDRESS\` with your TrancheFactory address

2. Run the script:
\`\`\`bash
npm run create-vault
\`\`\`

3. Note the vault address from output

## 🧪 Step 6: Test Deployment

\`\`\`bash
# Run local tests
npx hardhat test

# Test on testnet (optional)
npx hardhat console --network mantleTestnet
\`\`\`

## 🌐 Step 7: Explore on Block Explorer

Visit: https://explorer.testnet.mantle.xyz

Search for your contract addresses to view:
- Contract code
- Transactions
- Events
- Token transfers

## 📊 Contract Interaction Examples

### Update Property Data (OracleAdapter)
\`\`\`javascript
const oracle = await ethers.getContractAt("OracleAdapter", ORACLE_ADDRESS);
await oracle.updatePropertyData(
  "PROP_001",
  9200, // 92% occupancy
  500000000 // $5,000/month
);
\`\`\`

### Create New Vault (TrancheFactory)
\`\`\`javascript
const factory = await ethers.getContractAt("TrancheFactory", FACTORY_ADDRESS);
const tx = await factory.createVault(
  "PROP_001",
  "Property Senior Token",
  "PROP-SEN",
  "Property Junior Token",
  "PROP-JUN",
  7000, // 70% senior
  3000, // 30% junior
  500,  // 5% yield target
  1000, // 10% risk buffer
  STABLECOIN_ADDRESS
);
\`\`\`

### Deposit to Vault
\`\`\`javascript
const vault = await ethers.getContractAt("TrancheVault", VAULT_ADDRESS);

// Approve stablecoin first
const stablecoin = await ethers.getContractAt("IERC20", STABLECOIN_ADDRESS);
await stablecoin.approve(VAULT_ADDRESS, amount);

// Deposit to senior tranche
await vault.deposit(true, amount);

// Deposit to junior tranche
await vault.deposit(false, amount);
\`\`\`

## 🐛 Troubleshooting

### "Invalid private key"
- Ensure PRIVATE_KEY in .env is 64 characters (without 0x)
- Check for extra spaces or newlines

### "Insufficient funds"
- Get more testnet MNT from faucet
- Wait for faucet cooldown period

### "Transaction reverted"
- Check contract state
- Verify function parameters
- Review gas settings

### Compilation errors
- Run: \`rm -rf artifacts cache\`
- Then: \`npx hardhat clean && npx hardhat compile\`

## 📈 Gas Estimates

Approximate gas costs on Mantle Testnet:

| Operation | Gas Cost | Testnet Cost |
|-----------|----------|--------------|
| Deploy OracleAdapter | ~800k gas | ~Free |
| Deploy TrancheFactory | ~2.5M gas | ~Free |
| Create Vault | ~3.5M gas | ~Free |
| Deposit | ~150k gas | ~Free |
| Distribute Yield | ~100k gas | ~Free |

## 🔐 Security Reminders

1. **Never share your private key**
2. **Use a separate wallet for testing**
3. **Double-check contract addresses before interacting**
4. **Test on testnet before mainnet**
5. **Verify contracts after deployment**

## �� Support

If you encounter issues:
1. Check Hardhat docs: https://hardhat.org
2. Mantle docs: https://docs.mantle.xyz
3. OpenZeppelin docs: https://docs.openzeppelin.com

## 🎉 Success Indicators

✅ OracleAdapter deployed
✅ TrancheFactory deployed
✅ Demo property data initialized
✅ Contracts verified on explorer
✅ Demo vault created
✅ Ready for user interaction!

## 🚦 Next Steps After Deployment

1. **Build Frontend**: Start with the frontend template in \`/frontend\`
2. **Add More Properties**: Use the factory to create vaults for different properties
3. **Integrate Real Oracles**: Connect to real property data feeds
4. **Add Governance**: Implement DAO for protocol decisions
5. **Audit**: Get smart contract audit before mainnet

---

**Good luck with your deployment! 🚀**
