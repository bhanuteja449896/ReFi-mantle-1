const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Real Estate Tokenization System", function() {
  let oracleAdapter, factory, owner, addr1, addr2;
  
  beforeEach(async function() {
    [owner, addr1, addr2] = await ethers.getSigners();
    
    // Deploy OracleAdapter
    const OracleAdapter = await ethers.getContractFactory("OracleAdapter");
    oracleAdapter = await OracleAdapter.deploy();
    await oracleAdapter.deployed();
    
    // Deploy TrancheFactory
    const TrancheFactory = await ethers.getContractFactory("TrancheFactory");
    factory = await TrancheFactory.deploy(oracleAdapter.address);
    await factory.deployed();
    
    // Add sample property data
    await oracleAdapter.updatePropertyData(
      "TEST_PROP_001",
      9000, // 90% occupancy
      100000000 // $1,000/month
    );
  });
  
  describe("OracleAdapter", function() {
    it("Should update and retrieve property data", async function() {
      await oracleAdapter.updatePropertyData("TEST_PROP_002", 9500, 200000000);
      
      const data = await oracleAdapter.propertyData("TEST_PROP_002");
      expect(data.occupancyRate).to.equal(9500);
      expect(data.rentalIncome).to.equal(200000000);
    });
    
    it("Should calculate risk score correctly", async function() {
      const riskScore = await oracleAdapter.calculateRiskScore("TEST_PROP_001");
      expect(riskScore).to.be.greaterThan(0);
    });
    
    it("Should reject invalid occupancy rates", async function() {
      await expect(
        oracleAdapter.updatePropertyData("TEST_PROP_003", 10001, 100000000)
      ).to.be.revertedWith("Invalid occupancy");
    });
    
    it("Should track last update timestamp", async function() {
      await oracleAdapter.updatePropertyData("TEST_PROP_004", 8800, 150000000);
      const data = await oracleAdapter.propertyData("TEST_PROP_004");
      expect(data.lastUpdate).to.be.greaterThan(0);
    });
  });
  
  describe("TrancheFactory", function() {
    it("Should create a new vault", async function() {
      const tx = await factory.createVault(
        "TEST_PROP_001",
        "Test Senior",
        "TEST-SEN",
        "Test Junior", 
        "TEST-JUN",
        7000, // 70%
        3000, // 30%
        500,  // 5%
        1000, // 10%
        owner.address // Mock stablecoin
      );
      
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === 'VaultCreated');
      
      expect(event).to.not.be.undefined;
      expect(event.args.propertyId).to.equal("TEST_PROP_001");
      expect(event.args.creator).to.equal(owner.address);
    });
    
    it("Should reject invalid ratios", async function() {
      await expect(
        factory.createVault(
          "TEST_PROP_001",
          "Test Senior",
          "TEST-SEN",
          "Test Junior",
          "TEST-JUN",
          6000, // 60%
          5000, // 50% (Total 110%)
          500,
          1000,
          owner.address
        )
      ).to.be.revertedWith("Invalid ratios");
    });
    
    it("Should reject senior ratio outside 50-90% range", async function() {
      await expect(
        factory.createVault(
          "TEST_PROP_001",
          "Test Senior",
          "TEST-SEN",
          "Test Junior",
          "TEST-JUN",
          4000, // 40% (too low)
          6000, // 60%
          500,
          1000,
          owner.address
        )
      ).to.be.revertedWith("Senior ratio 50-90%");
    });
    
    it("Should track all deployed vaults", async function() {
      await factory.createVault(
        "TEST_PROP_001",
        "Test Senior 1",
        "TEST-SEN1",
        "Test Junior 1",
        "TEST-JUN1",
        7000,
        3000,
        500,
        1000,
        owner.address
      );
      
      await factory.createVault(
        "TEST_PROP_002",
        "Test Senior 2",
        "TEST-SEN2",
        "Test Junior 2",
        "TEST-JUN2",
        6000,
        4000,
        600,
        1500,
        owner.address
      );
      
      const vaults = await factory.getVaults();
      expect(vaults.length).to.equal(2);
      expect(vaults[0].propertyId).to.equal("TEST_PROP_001");
      expect(vaults[1].propertyId).to.equal("TEST_PROP_002");
    });
  });
  
  describe("TrancheVault", function() {
    let vault, vaultAddress;
    
    beforeEach(async function() {
      // Create a vault first
      const tx = await factory.createVault(
        "TEST_PROP_001",
        "Test Senior",
        "TEST-SEN",
        "Test Junior",
        "TEST-JUN",
        7000,
        3000,
        500,
        1000,
        owner.address
      );
      
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === 'VaultCreated');
      vaultAddress = event.args.vault;
      
      const TrancheVault = await ethers.getContractFactory("TrancheVault");
      vault = TrancheVault.attach(vaultAddress);
    });
    
    it("Should have correct initial configuration", async function() {
      expect(await vault.propertyId()).to.equal("TEST_PROP_001");
      expect(await vault.oracleAdapter()).to.equal(oracleAdapter.address);
    });
    
    it("Should be active after creation", async function() {
      expect(await vault.isActive()).to.equal(true);
    });
    
    it("Should create senior and junior tokens", async function() {
      const seniorTokenAddress = await vault.seniorToken();
      const juniorTokenAddress = await vault.juniorToken();
      
      expect(seniorTokenAddress).to.not.equal(ethers.constants.AddressZero);
      expect(juniorTokenAddress).to.not.equal(ethers.constants.AddressZero);
    });
    
    it("Should have correct tranche ratios", async function() {
      const config = await vault.config();
      expect(config.seniorRatio).to.equal(7000);
      expect(config.juniorRatio).to.equal(3000);
    });
    
    it("Should have correct yield targets", async function() {
      const config = await vault.config();
      expect(config.seniorYieldTarget).to.equal(500); // 5%
      expect(config.juniorYieldTarget).to.equal(1000); // 10% (double)
    });
    
    it("Should prevent reinitialization", async function() {
      await expect(
        vault.initialize(
          owner.address,
          "TEST_PROP_001",
          "Test Senior",
          "TEST-SEN",
          "Test Junior",
          "TEST-JUN",
          7000,
          3000,
          500,
          1000,
          oracleAdapter.address,
          owner.address
        )
      ).to.be.revertedWith("Already initialized");
    });
    
    it("Should allow owner to pause and unpause", async function() {
      // Pause the vault
      await vault.pause();
      
      // Check it's paused
      expect(await vault.paused()).to.equal(true);
      
      // Unpause
      await vault.unpause();
      
      // Check it's unpaused
      expect(await vault.paused()).to.equal(false);
    });
  });
});

console.log("✅ Test file created. Run with: npx hardhat test");
