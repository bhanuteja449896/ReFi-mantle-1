const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying Real Estate Tokenization System on Mantle...");
  
  // Deploy Oracle Adapter
  console.log("📊 Deploying OracleAdapter...");
  const OracleAdapter = await hre.ethers.getContractFactory("OracleAdapter");
  const oracleAdapter = await OracleAdapter.deploy();
  await oracleAdapter.deployed();
  console.log("✅ OracleAdapter deployed to:", oracleAdapter.address);
  
  // Deploy Tranche Factory
  console.log("🏭 Deploying TrancheFactory...");
  const TrancheFactory = await hre.ethers.getContractFactory("TrancheFactory");
  const trancheFactory = await TrancheFactory.deploy(oracleAdapter.address);
  await trancheFactory.deployed();
  console.log("✅ TrancheFactory deployed to:", trancheFactory.address);
  
  // Initialize with sample data for hackathon demo
  console.log("📝 Setting up demo property data...");
  await oracleAdapter.updatePropertyData(
    "NYC_APT_001",
    9200, // 92% occupancy
    500000000 // $5,000/month = 5,000 * 100,000 (8 decimals)
  );
  
  await oracleAdapter.updatePropertyData(
    "SF_OFFICE_002", 
    8500, // 85% occupancy
    1500000000 // $15,000/month
  );
  
  console.log("\n🎉 DEPLOYMENT COMPLETE!");
  console.log("==================================");
  console.log("Oracle Adapter:", oracleAdapter.address);
  console.log("Tranche Factory:", trancheFactory.address);
  console.log("\n💡 Next steps:");
  console.log("1. Run: npx hardhat verify --network mantleTestnet", oracleAdapter.address);
  console.log("2. Run: npx hardhat verify --network mantleTestnet", trancheFactory.address);
  console.log("3. Test with: npx hardhat test");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
