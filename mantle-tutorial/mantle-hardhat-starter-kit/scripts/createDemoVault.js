const hre = require("hardhat");

async function main() {
  // Configuration for demo vault
  const config = {
    propertyId: "NYC_APT_001",
    seniorName: "NYC Senior Tranche",
    seniorSymbol: "NYC-SEN",
    juniorName: "NYC Junior Tranche", 
    juniorSymbol: "NYC-JUN",
    seniorRatio: 7000, // 70%
    juniorRatio: 3000, // 30%
    seniorYieldTarget: 500, // 5%
    riskBuffer: 1000, // 10%
    // Use deployer address as mock stablecoin for testing
    // In production, use actual USDC/USDT address
    stablecoin: process.env.STABLECOIN_ADDRESS || "0x09Bc4E0D864854c6aFB6eB9A9cdF58aC190D0dF9" // Fallback to example address
  };
  
  console.log("🏗️ Creating demo tranche vault...");
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Using account:", deployer.address);
  
  // Get factory contract - update this after deployment
  const factoryAddress = process.env.FACTORY_ADDRESS || "REPLACE_WITH_FACTORY_ADDRESS";
  
  if (factoryAddress === "REPLACE_WITH_FACTORY_ADDRESS") {
    console.error("❌ Error: Please set FACTORY_ADDRESS in .env or update this script");
    console.log("Run deployment first: npm run deploy:testnet");
    process.exit(1);
  }
  
  const TrancheFactory = await hre.ethers.getContractFactory("TrancheFactory");
  const factory = TrancheFactory.attach(factoryAddress);
  
  console.log("Creating vault for property:", config.propertyId);
  console.log("Stablecoin address:", config.stablecoin);
  
  const tx = await factory.createVault(
    config.propertyId,
    config.seniorName,
    config.seniorSymbol,
    config.juniorName,
    config.juniorSymbol,
    config.seniorRatio,
    config.juniorRatio,
    config.seniorYieldTarget,
    config.riskBuffer,
    config.stablecoin
  );
  
  const receipt = await tx.wait();
  
  // Find vault address from event
  const event = receipt.events?.find(e => e.event === 'VaultCreated');
  const vaultAddress = event.args.vault;
  
  console.log("✅ Demo vault created!");
  console.log("Vault Address:", vaultAddress);
  console.log("Property ID:", config.propertyId);
  console.log("Senior Token: 70% with 5% target yield");
  console.log("Junior Token: 30% with risk buffer: 10%");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
