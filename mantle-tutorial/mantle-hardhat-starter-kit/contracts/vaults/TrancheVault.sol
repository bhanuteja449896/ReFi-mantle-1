// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../tokens/SeniorToken.sol";
import "../tokens/JuniorToken.sol";
import "../OracleAdapter.sol";

contract TrancheVault is Ownable, ReentrancyGuard, Pausable {
    struct TrancheConfig {
        uint256 seniorRatio; // Basis points
        uint256 juniorRatio;
        uint256 seniorYieldTarget; // Basis points
        uint256 juniorYieldTarget;
        uint256 riskBuffer; // Basis points
        uint256 totalDeposits;
        uint256 seniorDeposits;
        uint256 juniorDeposits;
        uint256 accumulatedYield;
    }
    
    string public propertyId;
    OracleAdapter public oracleAdapter;
    SeniorToken public seniorToken;
    JuniorToken public juniorToken;
    TrancheConfig public config;
    
    address public stablecoin; // USDC address
    
    bool public isActive;
    uint256 public lastRebalanceTime;
    
    event Deposited(address indexed user, bool isSenior, uint256 amount, uint256 tokensMinted);
    event Withdrawn(address indexed user, bool isSenior, uint256 amount, uint256 tokensBurned);
    event YieldDistributed(uint256 seniorYield, uint256 juniorYield, uint256 timestamp);
    event Rebalanced(uint256 newSeniorYield, uint256 newJuniorYield, uint256 riskBuffer);
    event EmergencyPaused(address indexed by, uint256 timestamp);
    event EmergencyUnpaused(address indexed by, uint256 timestamp);
    
    constructor() {
        // Initialize in separate function
    }
    
    function initialize(
        address _owner,
        string memory _propertyId,
        string memory seniorName,
        string memory seniorSymbol,
        string memory juniorName,
        string memory juniorSymbol,
        uint256 _seniorRatio,
        uint256 _juniorRatio,
        uint256 _seniorYieldTarget,
        uint256 _riskBuffer,
        address _oracleAdapter,
        address _stablecoin
    ) external {
        require(!isActive, "Already initialized");
        _transferOwnership(_owner);
        
        propertyId = _propertyId;
        oracleAdapter = OracleAdapter(_oracleAdapter);
        stablecoin = _stablecoin;
        
        // Create tokens
        seniorToken = new SeniorToken(seniorName, seniorSymbol);
        juniorToken = new JuniorToken(juniorName, juniorSymbol);
        seniorToken.setVault(address(this));
        juniorToken.setVault(address(this));
        
        config = TrancheConfig({
            seniorRatio: _seniorRatio,
            juniorRatio: _juniorRatio,
            seniorYieldTarget: _seniorYieldTarget,
            juniorYieldTarget: _seniorYieldTarget * 2, // Junior gets double yield
            riskBuffer: _riskBuffer,
            totalDeposits: 0,
            seniorDeposits: 0,
            juniorDeposits: 0,
            accumulatedYield: 0
        });
        
        isActive = true;
    }
    
    function deposit(bool isSenior, uint256 amount) external nonReentrant whenNotPaused {
        require(isActive, "Vault not active");
        require(amount > 0, "Zero amount");
        
        // Check tranche capacity
        if (isSenior) {
            uint256 maxSenior = config.totalDeposits * config.seniorRatio / 10000;
            require(config.seniorDeposits + amount <= maxSenior, "Senior tranche full");
            config.seniorDeposits += amount;
        } else {
            uint256 maxJunior = config.totalDeposits * config.juniorRatio / 10000;
            require(config.juniorDeposits + amount <= maxJunior, "Junior tranche full");
            config.juniorDeposits += amount;
        }
        
        config.totalDeposits += amount;
        
        // Transfer stablecoins
        IERC20(stablecoin).transferFrom(msg.sender, address(this), amount);
        
        // Mint tranche tokens (1:1 initially)
        uint256 tokensToMint = amount;
        
        if (isSenior) {
            seniorToken.mint(msg.sender, tokensToMint);
        } else {
            juniorToken.mint(msg.sender, tokensToMint);
        }
        
        emit Deposited(msg.sender, isSenior, amount, tokensToMint);
    }
    
    function withdraw(bool isSenior, uint256 tokenAmount) external nonReentrant whenNotPaused {
        require(isActive, "Vault not active");
        require(tokenAmount > 0, "Zero amount");
        
        // Check user has enough tokens
        if (isSenior) {
            require(seniorToken.balanceOf(msg.sender) >= tokenAmount, "Insufficient senior tokens");
        } else {
            require(juniorToken.balanceOf(msg.sender) >= tokenAmount, "Insufficient junior tokens");
        }
        
        // Calculate withdrawal amount (1:1 for now, can add share price logic later)
        uint256 withdrawAmount = tokenAmount;
        
        // Check vault has enough liquidity
        require(IERC20(stablecoin).balanceOf(address(this)) >= withdrawAmount, "Insufficient liquidity");
        
        // Update tranche deposits
        if (isSenior) {
            config.seniorDeposits -= withdrawAmount;
            seniorToken.burn(msg.sender, tokenAmount);
        } else {
            config.juniorDeposits -= withdrawAmount;
            juniorToken.burn(msg.sender, tokenAmount);
        }
        
        config.totalDeposits -= withdrawAmount;
        
        // Transfer stablecoins back
        IERC20(stablecoin).transfer(msg.sender, withdrawAmount);
        
        emit Withdrawn(msg.sender, isSenior, withdrawAmount, tokenAmount);
    }
    
    function distributeYield(uint256 yieldAmount) external onlyOwner {
        require(yieldAmount > 0, "No yield");
        
        // Calculate distribution based on risk-adjusted formula
        uint256 riskScore = oracleAdapter.calculateRiskScore(propertyId);
        
        // Senior gets priority, then junior
        uint256 seniorPortion = yieldAmount * config.seniorYieldTarget / 10000;
        uint256 juniorPortion = yieldAmount - seniorPortion;
        
        // Adjust based on risk buffer
        if (riskScore > 5000) { // High risk
            uint256 bufferAmount = juniorPortion * config.riskBuffer / 10000;
            seniorPortion += bufferAmount;
            juniorPortion -= bufferAmount;
        }
        
        // Distribute to token holders via token minting
        if (seniorToken.totalSupply() > 0) {
            uint256 seniorPerToken = seniorPortion * 1e18 / seniorToken.totalSupply();
            // In production, would mint additional tokens or distribute stablecoins
        }
        
        if (juniorToken.totalSupply() > 0) {
            uint256 juniorPerToken = juniorPortion * 1e18 / juniorToken.totalSupply();
        }
        
        config.accumulatedYield += yieldAmount;
        emit YieldDistributed(seniorPortion, juniorPortion, block.timestamp);
    }
    
    function rebalance() external {
        require(block.timestamp >= lastRebalanceTime + 7 days, "Cooldown active");
        
        // Get latest property data
        (uint256 occupancyRate, uint256 rentalIncome,,) = oracleAdapter.getPropertyData(propertyId);
        
        // Dynamic adjustment based on occupancy
        if (occupancyRate < 8000) { // Below 80% occupancy
            config.riskBuffer = config.riskBuffer * 120 / 100; // Increase buffer by 20%
            config.seniorYieldTarget = config.seniorYieldTarget * 90 / 100; // Reduce senior yield
        } else if (occupancyRate > 9500) { // Above 95% occupancy
            config.riskBuffer = config.riskBuffer * 80 / 100; // Decrease buffer
            config.juniorYieldTarget = config.juniorYieldTarget * 120 / 100; // Increase junior yield
        }
        
        lastRebalanceTime = block.timestamp;
        emit Rebalanced(config.seniorYieldTarget, config.juniorYieldTarget, config.riskBuffer);
    }
    
    // Emergency functions
    function pause() external onlyOwner {
        _pause();
        emit EmergencyPaused(msg.sender, block.timestamp);
    }
    
    function unpause() external onlyOwner {
        _unpause();
        emit EmergencyUnpaused(msg.sender, block.timestamp);
    }
    
    // View functions
    function getVaultBalance() external view returns (uint256) {
        return IERC20(stablecoin).balanceOf(address(this));
    }
    
    function getUserBalance(address user, bool isSenior) external view returns (uint256) {
        if (isSenior) {
            return seniorToken.balanceOf(user);
        } else {
            return juniorToken.balanceOf(user);
        }
    }
}
