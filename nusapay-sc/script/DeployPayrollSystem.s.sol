// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OriginPayroll} from "../src/OriginPayroll.sol";
import {DestinationPayrollBatch} from "../src/DestinationPayrollBatch.sol";

/**
 * @title DeployPayrollSystem
 * @dev Deployment script for NusaPay Cross-Chain Batch Payroll System
 * Deploys OriginPayroll on Core Testnet and DestinationPayrollBatch on Base Testnet
 */
contract DeployPayrollSystem is Script {
    // Core Testnet (Origin Chain) - Chain ID: 1114
    uint256 public constant CORE_CHAIN_ID = 1114;
    
    // Base Sepolia (Destination Chain) - Chain ID: 84532
    uint256 public constant BASE_CHAIN_ID = 84532;

    // Core Testnet Hyperlane addresses
    address public constant CORE_MAILBOX = 0xFBD43c6039f8EB2eE6C2Cc3CD2DAAE985E564508;
    address public constant CORE_IGP = 0xff0A4f733B2cF5f8C7869e42f3D92f54226BdE0A;

    // Base Sepolia Hyperlane addresses
    address public constant BASE_MAILBOX = 0xd5b993dB69c2263086C88870b47eec787b5427B8;

    // USDC Testnet addresses (you need to update these with actual testnet USDC addresses)
    address public constant USDC_BASE_SEPOLIA = 0x036CBD53842c5426634e7929541ec2318F3DCF7C; // Update with actual USDC address

    // Deployed contract addresses (will be set after deployment)
    OriginPayroll public originPayroll;
    DestinationPayrollBatch public destinationPayroll;

    function setUp() public {
        // Set up for Core Testnet deployment
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        console.log("NusaPay Cross-Chain Payroll System Deployment");
        console.log("=============================================");
        console.log("Deploying on Core Testnet (Chain ID:", CORE_CHAIN_ID, ")");
        console.log("Core Mailbox:", CORE_MAILBOX);
        console.log("Core IGP:", CORE_IGP);
        console.log("");

        // Deploy OriginPayroll on Core Testnet
        // Note: destinationPayroll address will be set after Base deployment
        originPayroll = new OriginPayroll(
            CORE_MAILBOX,
            CORE_IGP,
            address(0), // Will be updated after Base deployment
            BASE_CHAIN_ID
        );

        console.log("OriginPayroll deployed on Core Testnet");
        console.log("   Address:", address(originPayroll));
        console.log("");

        vm.stopBroadcast();

        // Switch to Base Sepolia for destination deployment
        console.log("Switching to Base Sepolia (Chain ID:", BASE_CHAIN_ID, ")");
        console.log("Base Mailbox:", BASE_MAILBOX);
        console.log("USDC Token:", USDC_BASE_SEPOLIA);
        console.log("");

        vm.createSelectFork(vm.rpcUrl("base_sepolia"));

        vm.startBroadcast(privateKey);

        // Deploy DestinationPayrollBatch on Base Sepolia
        destinationPayroll = new DestinationPayrollBatch(
            BASE_MAILBOX,
            USDC_BASE_SEPOLIA
        );

        console.log("DestinationPayrollBatch deployed on Base Sepolia");
        console.log("   Address:", address(destinationPayroll));
        console.log("");

        vm.stopBroadcast();

        // Switch back to Core Testnet to update the destination address
        console.log("Updating OriginPayroll with destination address...");
        vm.createSelectFork(vm.rpcUrl("core_testnet"));

        vm.startBroadcast(privateKey);

        // Update the destination payroll address in OriginPayroll
        originPayroll.setDestinationPayroll(address(destinationPayroll));

        console.log("OriginPayroll destination address updated");
        console.log("   Destination Address:", address(destinationPayroll));
        console.log("");

        // Final configuration verification
        console.log("Final Configuration:");
        console.log("====================");
        console.log("OriginPayroll (Core Testnet):", address(originPayroll));
        console.log("DestinationPayrollBatch (Base Sepolia):", address(destinationPayroll));
        console.log("");
        console.log("Deployment Complete!");
        console.log("");
        console.log("Next Steps:");
        console.log("1. Fund the DestinationPayrollBatch contract with USDC");
        console.log("2. Test the payroll batch execution");
        console.log("3. Monitor events for salary payments and fiat simulation");

        vm.stopBroadcast();
    }

    /**
     * @dev Helper function to deploy only OriginPayroll (for testing)
     */
    function deployOriginOnly() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        console.log("Deploying OriginPayroll only...");
        
        originPayroll = new OriginPayroll(
            CORE_MAILBOX,
            CORE_IGP,
            address(0), // Placeholder
            BASE_CHAIN_ID
        );

        console.log("OriginPayroll deployed:", address(originPayroll));

        vm.stopBroadcast();
    }

    /**
     * @dev Helper function to deploy only DestinationPayrollBatch (for testing)
     */
    function deployDestinationOnly() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        console.log("Deploying DestinationPayrollBatch only...");
        
        destinationPayroll = new DestinationPayrollBatch(
            BASE_MAILBOX,
            USDC_BASE_SEPOLIA
        );

        console.log("DestinationPayrollBatch deployed:", address(destinationPayroll));

        vm.stopBroadcast();
    }
} 