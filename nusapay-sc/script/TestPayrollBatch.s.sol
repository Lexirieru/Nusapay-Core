// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {OriginPayroll} from "../src/OriginPayroll.sol";
import {DestinationPayrollBatch} from "../src/DestinationPayrollBatch.sol";

/**
 * @title TestPayrollBatch
 * @dev Test script to demonstrate the complete cross-chain batch payroll flow
 * This script shows how to execute a batch payroll from Core Testnet to Base Sepolia
 */
contract TestPayrollBatch is Script {
    // Chain IDs
    uint256 public constant CORE_CHAIN_ID = 1114;
    uint256 public constant BASE_CHAIN_ID = 84532;

    // Hyperlane addresses
    address public constant CORE_MAILBOX = 0xFBD43c6039f8EB2eE6C2Cc3CD2DAAE985E564508;
    address public constant CORE_IGP = 0xff0A4f733B2cF5f8C7869e42f3D92f54226BdE0A;
    address public constant BASE_MAILBOX = 0xd5b993dB69c2263086C88870b47eec787b5427B8;

    // USDC testnet address on Base Sepolia
    address public constant USDC_BASE_SEPOLIA = 0x036CBD53842c5426634e7929541ec2318F3DCF7C;

    // Deployed contract addresses (update these after deployment)
    address public originPayrollAddress = 0x0000000000000000000000000000000000000000; // UPDATE
    address public destinationPayrollAddress = 0x0000000000000000000000000000000000000000; // UPDATE

    // Test wallet
    address public testWallet = 0xBB241303F947f6E223CA400aECEe04693e854b44; // UPDATE

    // Test employee data
    address[] public testEmployees;
    uint256[] public cryptoAmounts;
    uint256[] public fiatAmounts;
    string[] public currencies;
    string[] public bankAccounts;

    function setUp() public {
        // Set up test data
        testEmployees = [
            0x1234567890123456789012345678901234567890, // Employee 1
            0x2345678901234567890123456789012345678901, // Employee 2
            0x3456789012345678901234567890123456789012  // Employee 3
        ];

        cryptoAmounts = [
            1000e6, // 1000 USDC (6 decimals)
            1500e6, // 1500 USDC
            2000e6  // 2000 USDC
        ];

        fiatAmounts = [
            15000000, // 15,000,000 IDR
            22500000, // 22,500,000 IDR
            30000000  // 30,000,000 IDR
        ];

        currencies = [
            "IDR",
            "IDR", 
            "IDR"
        ];

        bankAccounts = [
            "BCA 1234567890",
            "Mandiri 0987654321",
            "BNI 1122334455"
        ];
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("NusaPay Cross-Chain Batch Payroll Test");
        console.log("=====================================");
        console.log("Test Wallet:", testWallet);
        console.log("OriginPayroll:", originPayrollAddress);
        console.log("DestinationPayrollBatch:", destinationPayrollAddress);
        console.log("");

        // STEP 1: Execute batch payroll on Core Testnet
        console.log("STEP 1: Executing Batch Payroll on Core Testnet");
        console.log("================================================");
        
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
        
        vm.startBroadcast(privateKey);

        // Verify contract addresses
        if (originPayrollAddress == address(0)) {
            console.log("ERROR: OriginPayroll address not set");
            console.log("Please update the address in the script");
            return;
        }

        OriginPayroll originPayroll = OriginPayroll(originPayrollAddress);

        // Check contract configuration
        (address mailbox, address igp, address destPayroll, uint256 destChain) = originPayroll.getConfig();
        console.log("Contract Configuration:");
        console.log("  Mailbox:", mailbox);
        console.log("  IGP:", igp);
        console.log("  Destination Payroll:", destPayroll);
        console.log("  Destination Chain ID:", destChain);
        console.log("");

        // Execute batch payroll
        console.log("Executing batch payroll...");
        console.log("Employees:", testEmployees.length);
        console.log("Total Crypto Amount:", _calculateTotal(cryptoAmounts), "USDC");
        console.log("Total Fiat Amount:", _calculateTotal(fiatAmounts), "IDR");
        console.log("");

        // Estimate gas payment (you may need to adjust this)
        uint256 estimatedGasPayment = 0.01 ether; // Adjust based on actual gas costs

        bytes32 messageId = originPayroll.executePayrollBatch{value: estimatedGasPayment}(
            testEmployees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );

        console.log("Batch payroll executed successfully!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("Cross-chain message sent to Base Sepolia");
        console.log("");

        vm.stopBroadcast();

        // STEP 2: Check destination contract on Base Sepolia
        console.log("STEP 2: Checking Destination Contract on Base Sepolia");
        console.log("=====================================================");
        
        vm.createSelectFork(vm.rpcUrl("base_sepolia"));

        if (destinationPayrollAddress == address(0)) {
            console.log("ERROR: DestinationPayrollBatch address not set");
            console.log("Please update the address in the script");
            return;
        }

        DestinationPayrollBatch destinationPayroll = DestinationPayrollBatch(payable(destinationPayrollAddress));

        // Check USDC balance of destination contract
        uint256 usdcBalance = destinationPayroll.getUsdcBalance();
        console.log("Destination Contract USDC Balance:", usdcBalance);
        
        uint256 requiredAmount = _calculateTotal(cryptoAmounts);
        console.log("Required Amount:", requiredAmount);
        
        if (usdcBalance < requiredAmount) {
            console.log("WARNING: Insufficient USDC balance in destination contract");
            console.log("Please fund the contract with at least", requiredAmount, "USDC");
            console.log("");
            console.log("To fund the contract, transfer USDC to:", destinationPayrollAddress);
        } else {
            console.log("Sufficient USDC balance for payroll processing");
        }

        // Check contract configuration
        (address destMailbox, address usdcToken) = destinationPayroll.getConfig();
        console.log("Destination Contract Configuration:");
        console.log("  Mailbox:", destMailbox);
        console.log("  USDC Token:", usdcToken);
        console.log("");

        // STEP 3: Simulate message processing (for demo purposes)
        console.log("STEP 3: Payroll Processing Simulation");
        console.log("=====================================");
        console.log("In a real scenario, the Hyperlane relayer would:");
        console.log("1. Pick up the message from Core Testnet");
        console.log("2. Deliver it to Base Sepolia");
        console.log("3. Trigger the handle() function on DestinationPayrollBatch");
        console.log("4. Process USDC transfers to employees");
        console.log("5. Emit SalaryPaid and FiatPaymentSimulated events");
        console.log("");
        console.log("Expected Events:");
        console.log("- SalaryPaid events for each employee");
        console.log("- FiatPaymentSimulated events for UI demo");
        console.log("- PayrollBatchProcessed event for completion");
        console.log("");

        // Display expected event data
        console.log("Expected Event Data:");
        console.log("====================");
        for (uint256 i = 0; i < testEmployees.length; i++) {
            console.log("Employee", i + 1, ":");
            console.log("  Address:", testEmployees[i]);
            console.log("  USDC Amount:", cryptoAmounts[i]);
            console.log("  Fiat Amount:", fiatAmounts[i], currencies[i]);
            console.log("  Bank Account:", bankAccounts[i]);
            console.log("");
        }

        console.log("Test demonstration complete!");
        console.log("");
        console.log("Next Steps:");
        console.log("1. Fund the destination contract with USDC");
        console.log("2. Wait for Hyperlane relayer to process the message");
        console.log("3. Monitor events on Base Sepolia");
        console.log("4. Verify USDC transfers to employee wallets");
    }

    /**
     * @dev Helper function to calculate total from array
     */
    function _calculateTotal(uint256[] memory amounts) internal pure returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }
        return total;
    }

    /**
     * @dev Function to fund destination contract with USDC (for testing)
     */
    function fundDestinationContract() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        
        vm.createSelectFork(vm.rpcUrl("base_sepolia"));
        
        vm.startBroadcast(privateKey);

        console.log("Funding destination contract with USDC...");
        
        // This would require you to have USDC tokens to transfer
        // In a real scenario, you'd need to get USDC from a faucet or exchange
        uint256 fundingAmount = 10000e6; // 10,000 USDC
        
        IERC20 usdc = IERC20(USDC_BASE_SEPOLIA);
        
        // Check if test wallet has enough USDC
        uint256 balance = usdc.balanceOf(testWallet);
        console.log("Test wallet USDC balance:", balance);
        
        if (balance >= fundingAmount) {
            // Transfer USDC to destination contract
            bool success = usdc.transfer(destinationPayrollAddress, fundingAmount);
            if (success) {
                console.log("Successfully funded destination contract with", fundingAmount, "USDC");
            } else {
                console.log("Failed to transfer USDC");
            }
        } else {
            console.log("Insufficient USDC balance in test wallet");
            console.log("Please get USDC from a faucet first");
        }

        vm.stopBroadcast();
    }
} 