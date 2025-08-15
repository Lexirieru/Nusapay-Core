// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OriginPayroll} from "../src/OriginPayroll.sol";
import {DestinationPayrollBatch} from "../src/DestinationPayrollBatch.sol";
import {MockUSDC} from "../src/mocks/MockUSDC.sol";
import {MockIDRX} from "../src/mocks/MockIDRX.sol";

/**
 * @title Shortcut_Payroll
 * @dev Shortcut script for NusaPay Cross-Chain Payroll deployment and execution
 * 
 * Usage:
 * 1. Deploy: forge script script/Shortcut_Payroll.s.sol:Shortcut_Payroll --sig "deploy()" --rpc-url core_testnet --broadcast
 * 2. Execute Payroll: forge script script/Shortcut_Payroll.s.sol:Shortcut_Payroll --sig "executePayroll()" --rpc-url core_testnet --broadcast
 * 3. Update Destination: forge script script/Shortcut_Payroll.s.sol:Shortcut_Payroll --sig "updateDestination(address)" --sig-args "0x..." --rpc-url core_testnet --broadcast
 */
contract Shortcut_Payroll is Script {
    
    // Chain IDs
    uint256 public constant CORE_CHAIN_ID = 1114;
    uint256 public constant BASE_CHAIN_ID = 84532;
    
    // Hyperlane addresses (Core Testnet)
    address public constant CORE_MAILBOX = 0xA948C6025FfCe453e359f72FAfc916F586e0BF26;
    address public constant CORE_IGP = 0x5558306914971922B959bAe5d7A2424FCD40230f;
    
    // Hyperlane addresses (Base Sepolia)
    address public constant BASE_MAILBOX = 0x80AA79da4F080Dbcdab8609C1A4DA20574A9Aa48;
    address public constant BASE_IGP = 0x525e7932623f4edf0a2CA85a565e98B70788AF74;
    
    // Test addresses
    address public axel = address(0xFA128bBD1846c19025c7428AEE403Fc06F0A9e38); // Company A owner
    address public alice = address(0x93f4Ca8B0135a3611cCB5Ee27742cd36656Ce071); // Employee 1
    address public bob = address(0x63470E56eFeB1759F3560500fB2d2FD43A86F179);   // Employee 2
    address public charlie = address(0x7467b5F2516fe3e843B354bCD1867BD80601382c); // Employee 3
    
    // Contract instances
    OriginPayroll public originPayroll;
    DestinationPayrollBatch public destinationPayroll;
    MockUSDC public mockUSDC;
    MockIDRX public mockIDRX;
    
    // Deployed token addresses
    address public constant DEPLOYED_USDC = 0x3dBFCF9B63F77125351866b7F2B027908810b4C0; // Mock USDC di Core Testnet
    address public constant DEPLOYED_IDRX = 0x16C6dc8220e61EDeba67758062B53b22366DA0c1; // Mock IDRX di Core Testnet
    
    // Test data
    address[] public employees;
    uint256[] public cryptoAmounts;
    uint256[] public fiatAmounts;
    string[] public currencies;
    string[] public bankAccounts;
    
    // Initial balances (USDC with 6 decimals)
    uint256 public constant AXEL_INITIAL_BALANCE = 4500e6; // 4500 USDC
    uint256 public constant ALICE_SALARY = 1000e6;  // 1000 USDC
    uint256 public constant BOB_SALARY = 2000e6;    // 2000 USDC
    uint256 public constant CHARLIE_SALARY = 1500e6; // 1500 USDC
    
    // IDRX balances (with 2 decimals)
    uint256 public constant AXEL_IDRX_BALANCE = 1500000e2; // 15,000,000 IDRX
    
    function setUp() public {
        // Set up test data
        employees = [alice, bob, charlie];
        cryptoAmounts = [ALICE_SALARY, BOB_SALARY, CHARLIE_SALARY];
        fiatAmounts = [
            15000000, // 15,000,000 IDR for Alice
            30000000, // 30,000,000 IDR for Bob
            22500000  // 22,500,000 IDR for Charlie
        ];
        currencies = ["IDR", "IDR", "IDR"];
        bankAccounts = [
            "BCA 1234567890",    // Alice's bank account
            "Mandiri 0987654321", // Bob's bank account
            "BNI 1122334455"     // Charlie's bank account
        ];
    }
    
    function run() external {
        console.log("NusaPay Cross-Chain Payroll Shortcut");
        console.log("Available functions:");
        console.log("1. deploy() - Deploy both contracts");
        console.log("2. executePayroll() - Execute batch payroll");
        console.log("3. executePayrollWithHighGas() - Execute payroll with higher gas payment");
        console.log("4. updateDestination(address) - Update destination contract address");
        console.log("5. deployOrigin() - Deploy OriginPayroll only");
        console.log("6. deployDestination() - Deploy DestinationPayroll only");
        console.log("7. setupTestData() - Setup test data and balances");
        console.log("");
        console.log("Example: forge script script/Shortcut_Payroll.s.sol:Shortcut_Payroll --sig \"deploy()\" --rpc-url core_testnet --broadcast");
    }
    
    function deploy() external {
        console.log("=== Deploying NusaPay Cross-Chain Payroll System ===");
        
        // Deploy OriginPayroll on Core Testnet
        console.log("Deploying OriginPayroll on Core Testnet...");
        vm.startBroadcast();
        
        // Deploy with placeholder destination address
        originPayroll = new OriginPayroll(
            CORE_MAILBOX,
            CORE_IGP,
            address(0x1234567890123456789012345678901234567890), // Placeholder
            BASE_CHAIN_ID
        );
        
        vm.stopBroadcast();
        
        console.log("OriginPayroll deployed at:", address(originPayroll));
        console.log("Owner:", originPayroll.owner());
        console.log("Mailbox:", originPayroll.mailbox());
        console.log("IGP:", originPayroll.interchainGasPaymaster());
        console.log("Destination Chain ID:", originPayroll.destinationChainId());
        
        console.log("");
        console.log("=== Deployment Summary ===");
        console.log("OriginPayroll (Core Testnet):", address(originPayroll));
        console.log("DestinationPayroll (Base Sepolia): Not deployed yet");
        console.log("");
        console.log("Next steps:");
        console.log("1. Deploy DestinationPayroll on Base Sepolia");
        console.log("2. Update OriginPayroll with DestinationPayroll address");
        console.log("3. Execute payroll batch");
    }
    
    function deployOrigin() external {
        console.log("=== Deploying OriginPayroll on Core Testnet ===");
        
        vm.startBroadcast();
        
        originPayroll = new OriginPayroll(
            CORE_MAILBOX,
            CORE_IGP,
            address(0x1234567890123456789012345678901234567890), // Placeholder
            BASE_CHAIN_ID
        );
        
        vm.stopBroadcast();
        
        console.log("OriginPayroll deployed at:", address(originPayroll));
        console.log("Owner:", originPayroll.owner());
        console.log("Mailbox:", originPayroll.mailbox());
        console.log("IGP:", originPayroll.interchainGasPaymaster());
        console.log("Destination Chain ID:", originPayroll.destinationChainId());
    }
    
    function deployDestination() external {
        console.log("=== Deploying DestinationPayroll on Base Sepolia ===");
        
        vm.startBroadcast();
        
        // Deploy mock USDC first
        mockUSDC = new MockUSDC();
        console.log("Mock USDC deployed at:", address(mockUSDC));
        
        destinationPayroll = new DestinationPayrollBatch(
            BASE_MAILBOX,
            address(mockUSDC) // Use deployed mock USDC
        );
        
        vm.stopBroadcast();
        
        console.log("DestinationPayroll deployed at:", address(destinationPayroll));
        console.log("Owner:", destinationPayroll.owner());
        console.log("Mailbox:", destinationPayroll.mailbox());
        console.log("USDC Token:", destinationPayroll.usdcToken());
    }
    
    function updateDestination(address destinationAddress) external {
        console.log("=== Updating Destination Contract Address ===");
        console.log("New destination address:", destinationAddress);
        
        // Load existing deployed OriginPayroll contract
        if (address(originPayroll) == address(0)) {
            originPayroll = OriginPayroll(0x63719d58c13AbaDad02d5390c7f83082F51De805);
            console.log("Loaded existing OriginPayroll at:", address(originPayroll));
        }
        
        vm.startBroadcast();
        
        originPayroll.setDestinationPayroll(destinationAddress);
        
        vm.stopBroadcast();
        
        console.log("Destination address updated successfully!");
        console.log("Current destination:", originPayroll.destinationPayroll());
    }
    
    function setupTestData() external {
        console.log("=== Setting up Test Data ===");
        
        vm.startBroadcast();
        
        // Deploy new Mock USDC
        mockUSDC = new MockUSDC();
        console.log("Deployed new Mock USDC at:", address(mockUSDC));
        
        // Deploy new Mock IDRX
        mockIDRX = new MockIDRX();
        console.log("Deployed new Mock IDRX at:", address(mockIDRX));
        
        // Mint USDC to Axel (6 decimals)
        mockUSDC.mint(axel, AXEL_INITIAL_BALANCE);
        console.log("Minted", AXEL_INITIAL_BALANCE / 1e6, "USDC to Axel");
        
        // Mint IDRX to Axel (2 decimals)
        mockIDRX.mint(axel, AXEL_IDRX_BALANCE);
        console.log("Minted", AXEL_IDRX_BALANCE / 1e2, "IDRX to Axel");
        
        vm.stopBroadcast();
        
        console.log("Test data setup completed!");
        console.log("Mock USDC deployed at:", address(mockUSDC));
        console.log("Mock IDRX deployed at:", address(mockIDRX));
        console.log("Axel USDC balance:", mockUSDC.balanceOf(axel) / 1e6, "USDC");
        console.log("Axel IDRX balance:", mockIDRX.balanceOf(axel) / 1e2, "IDRX");
    }
    
    function executePayroll() external {
        console.log("=== Executing Cross-Chain Batch Payroll ===");
        
        // Load existing deployed OriginPayroll contract
        if (address(originPayroll) == address(0)) {
            originPayroll = OriginPayroll(0x63719d58c13AbaDad02d5390c7f83082F51De805);
            console.log("Loaded existing OriginPayroll at:", address(originPayroll));
        }
        
        // Load existing deployed Mock USDC
        if (address(mockUSDC) == address(0)) {
            mockUSDC = MockUSDC(DEPLOYED_USDC);
            console.log("Loaded existing Mock USDC at:", address(mockUSDC));
        }
        
        console.log("Payroll Details:");
        console.log("- Axel (Company A):", vm.toString(axel));
        console.log("- Alice:", vm.toString(alice));
        console.log("- Bob:", vm.toString(bob));
        console.log("- Charlie:", vm.toString(charlie));
        console.log("- Total Salary:", vm.toString((ALICE_SALARY + BOB_SALARY + CHARLIE_SALARY) / 1e6), "USDC");
        
        vm.startBroadcast();
        
        // Mint USDC to Axel if needed
        uint256 axelBalance = mockUSDC.balanceOf(axel);
        uint256 requiredAmount = ALICE_SALARY + BOB_SALARY + CHARLIE_SALARY;
        
        if (axelBalance < requiredAmount) {
            uint256 mintAmount = requiredAmount - axelBalance + 1000e6; // Extra 1000 USDC
            mockUSDC.mint(axel, mintAmount);
            console.log("Minted", mintAmount / 1e6, "USDC to Axel");
        }
        
        // Approve OriginPayroll to spend USDC
        mockUSDC.approve(address(originPayroll), requiredAmount);
        console.log("Approved OriginPayroll to spend", requiredAmount / 1e6, "USDC");
        
        // Transfer USDC to OriginPayroll contract
        mockUSDC.transfer(address(originPayroll), requiredAmount);
        console.log("Transferred", requiredAmount / 1e6, "USDC to OriginPayroll contract");
        
        // Execute batch payroll with higher gas payment
        bytes32 messageId = originPayroll.executePayrollBatch (
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.stopBroadcast();
        
        console.log("Payroll batch executed successfully!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("Total employees:", employees.length);
        console.log("Total salary:", (ALICE_SALARY + BOB_SALARY + CHARLIE_SALARY) / 1e6, "USDC");
        console.log("Gas payment: 0.05 ETH");
        console.log("Axel USDC balance after:", mockUSDC.balanceOf(axel) / 1e6, "USDC");
        console.log("OriginPayroll USDC balance:", mockUSDC.balanceOf(address(originPayroll)) / 1e6, "USDC");
        console.log("");
        console.log("Next step: Process payroll on Base Sepolia (DestinationPayroll.handle)");
    }
    
    
    function getContractInfo() external view {
        console.log("=== Contract Information ===");
        
        // Load existing deployed OriginPayroll contract for info
        OriginPayroll originPayrollInfo = address(originPayroll) != address(0) ? 
            originPayroll : OriginPayroll(0x08fFf1e50a9B06829Ab9A15d23031FCb1161eBa5);
        
        if (address(originPayrollInfo) != address(0)) {
            console.log("OriginPayroll:", address(originPayrollInfo));
            console.log("Owner:", originPayrollInfo.owner());
            console.log("Destination:", originPayrollInfo.destinationPayroll());
            console.log("Mailbox:", originPayrollInfo.mailbox());
            console.log("IGP:", originPayrollInfo.interchainGasPaymaster());
            console.log("Destination Chain ID:", originPayrollInfo.destinationChainId());
        } else {
            console.log("OriginPayroll: Not deployed");
        }
        
        if (address(destinationPayroll) != address(0)) {
            console.log("DestinationPayroll:", address(destinationPayroll));
            console.log("Owner:", destinationPayroll.owner());
            console.log("USDC Token:", destinationPayroll.usdcToken());
            console.log("Mailbox:", destinationPayroll.mailbox());
        } else {
            console.log("DestinationPayroll: Not deployed");
        }
        
        console.log("Deployed Token Addresses:");
        console.log("Mock USDC (Core Testnet):", DEPLOYED_USDC);
        console.log("Mock IDRX (Core Testnet):", DEPLOYED_IDRX);
        
        if (address(mockUSDC) != address(0)) {
            console.log("Mock USDC:", address(mockUSDC));
            console.log("Axel USDC balance:", mockUSDC.balanceOf(axel) / 1e6, "USDC");
        } else {
            console.log("Mock USDC: Not loaded");
        }
        
        if (address(mockIDRX) != address(0)) {
            console.log("Mock IDRX:", address(mockIDRX));
            console.log("Axel IDRX balance:", mockIDRX.balanceOf(axel) / 1e2, "IDRX");
        } else {
            console.log("Mock IDRX: Not loaded");
        }
    }
} 