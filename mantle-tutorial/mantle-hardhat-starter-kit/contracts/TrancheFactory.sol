// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./vaults/TrancheVault.sol";

contract TrancheFactory is Ownable {
    using Clones for address;
    
    address public vaultImplementation;
    address public oracleAdapter;
    
    struct DeployedVault {
        address vaultAddress;
        string propertyId;
        address creator;
        uint256 timestamp;
    }
    
    DeployedVault[] public vaults;
    
    event VaultCreated(address indexed vault, string propertyId, address creator, uint256 timestamp);
    
    constructor(address _oracleAdapter) {
        vaultImplementation = address(new TrancheVault());
        oracleAdapter = _oracleAdapter;
    }
    
    function createVault(
        string memory propertyId,
        string memory seniorName,
        string memory seniorSymbol,
        string memory juniorName,
        string memory juniorSymbol,
        uint256 seniorRatio, // 7000 = 70%
        uint256 juniorRatio, // 3000 = 30%
        uint256 seniorYieldTarget, // 500 = 5%
        uint256 riskBuffer, // 1000 = 10%
        address stablecoin
    ) external returns (address) {
        require(seniorRatio + juniorRatio == 10000, "Invalid ratios");
        require(seniorRatio >= 5000 && seniorRatio <= 9000, "Senior ratio 50-90%");
        
        address clone = Clones.clone(vaultImplementation);
        
        TrancheVault(clone).initialize(
            msg.sender,
            propertyId,
            seniorName,
            seniorSymbol,
            juniorName,
            juniorSymbol,
            seniorRatio,
            juniorRatio,
            seniorYieldTarget,
            riskBuffer,
            oracleAdapter,
            stablecoin
        );
        
        vaults.push(DeployedVault({
            vaultAddress: clone,
            propertyId: propertyId,
            creator: msg.sender,
            timestamp: block.timestamp
        }));
        
        emit VaultCreated(clone, propertyId, msg.sender, block.timestamp);
        return clone;
    }
    
    function getVaults() external view returns (DeployedVault[] memory) {
        return vaults;
    }
}
