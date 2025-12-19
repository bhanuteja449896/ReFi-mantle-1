// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OracleAdapter is Ownable {
    struct PropertyData {
        uint256 occupancyRate; // Basis points (10000 = 100%)
        uint256 rentalIncome; // USD with 8 decimals
        uint256 vacancyRate;
        uint256 lastUpdate;
        bool isActive;
    }
    
    mapping(string => PropertyData) public propertyData;
    mapping(address => bool) public authorizedOracles;
    
    event PropertyDataUpdated(string propertyId, uint256 occupancyRate, uint256 rentalIncome, uint256 timestamp);
    
    constructor() {
        authorizedOracles[msg.sender] = true;
    }
    
    function updatePropertyData(string memory propertyId, uint256 occupancyRate, uint256 rentalIncome) external onlyAuthorizedOracle {
        require(occupancyRate <= 10000, "Invalid occupancy");
        
        propertyData[propertyId] = PropertyData({
            occupancyRate: occupancyRate,
            rentalIncome: rentalIncome,
            vacancyRate: 10000 - occupancyRate,
            lastUpdate: block.timestamp,
            isActive: true
        });
        
        emit PropertyDataUpdated(propertyId, occupancyRate, rentalIncome, block.timestamp);
    }
    
    function calculateRiskScore(string memory propertyId) public view returns (uint256) {
        PropertyData memory data = propertyData[propertyId];
        require(data.isActive, "Property inactive");
        return (10000 - data.occupancyRate) * 3 + data.vacancyRate * 2 / 5;
    }
    
    function getPropertyData(string memory propertyId) external view returns (uint256, uint256, uint256, uint256) {
        PropertyData memory data = propertyData[propertyId];
        return (data.occupancyRate, data.rentalIncome, data.vacancyRate, data.lastUpdate);
    }
    
    function authorizeOracle(address oracle, bool authorized) external onlyOwner {
        authorizedOracles[oracle] = authorized;
    }
    
    modifier onlyAuthorizedOracle() {
        require(authorizedOracles[msg.sender], "Unauthorized");
        _;
    }
}
