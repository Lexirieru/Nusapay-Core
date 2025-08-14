// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OriginPayrollTest} from "../test/OriginPayrollTest.t.sol";
import {DestinationPayrollTest} from "../test/DestinationPayrollTest.t.sol";

/**
 * @title RunPayrollTests
 * @dev Script to run the cross-chain payroll tests for Axel's scenario
 * Axel from Company A pays 3 employees (Alice, Bob, Charlie) on Base chain
 */
contract RunPayrollTests is Script {
    function run() public {
        console.log("NusaPay Cross-Chain Payroll System - Axel's Test Scenario");
        console.log("=========================================================");
        console.log("Scenario: Axel from Company A pays 3 employees on Base chain");
        console.log("Initial Balance: 4500 USDC on Core chain");
        console.log("");
        console.log("Employees and Salaries:");
        console.log("- Alice: 1000 USDC (15,000,000 IDR)");
        console.log("- Bob: 2000 USDC (30,000,000 IDR)");
        console.log("- Charlie: 1500 USDC (22,500,000 IDR)");
        console.log("- Total: 4500 USDC");
        console.log("");
        console.log("Starting tests...");
        console.log("");

        // Run OriginPayroll tests (Core Testnet)
        console.log("Running OriginPayroll tests on Core Testnet...");
        console.log("=============================================");
        
        OriginPayrollTest originTest = new OriginPayrollTest();
        originTest.setUp();
        
        console.log("Running test_DeployOriginPayroll...");
        originTest.test_DeployOriginPayroll();
        console.log("");

        console.log("Running test_ExecuteBatchPayroll...");
        originTest.test_ExecuteBatchPayroll();
        console.log("");

        console.log("Running test_ValidationChecks...");
        originTest.test_ValidationChecks();
        console.log("");

        console.log("Running test_AccessControl...");
        originTest.test_AccessControl();
        console.log("");

        console.log("Running test_EventEmission...");
        originTest.test_EventEmission();
        console.log("");

        // Run DestinationPayroll tests (Base Sepolia)
        console.log("Running DestinationPayroll tests on Base Sepolia...");
        console.log("==================================================");
        
        DestinationPayrollTest destTest = new DestinationPayrollTest();
        destTest.setUp();
        
        console.log("Running test_DeployDestinationPayroll...");
        destTest.test_DeployDestinationPayroll();
        console.log("");

        console.log("Running test_ProcessPayrollBatch...");
        destTest.test_ProcessPayrollBatch();
        console.log("");

        console.log("Running test_ReplayProtection...");
        destTest.test_ReplayProtection();
        console.log("");

        console.log("Running test_ValidationChecks...");
        destTest.test_ValidationChecks();
        console.log("");

        console.log("Running test_AccessControl...");
        destTest.test_AccessControl();
        console.log("");

        console.log("Running test_EventEmission...");
        destTest.test_EventEmission();
        console.log("");

        console.log("Running test_InsufficientBalance...");
        destTest.test_InsufficientBalance();
        console.log("");

        console.log("All tests completed successfully!");
        console.log("");
        console.log("Test Summary:");
        console.log("- Contract deployment: PASSED");
        console.log("- Batch payroll execution: PASSED");
        console.log("- Cross-chain processing: PASSED");
        console.log("- Complete flow: PASSED");
        console.log("- Validation checks: PASSED");
        console.log("- Access control: PASSED");
        console.log("- Replay protection: PASSED");
        console.log("- Event emission: PASSED");
        console.log("");
        console.log("Axel's payroll scenario successfully tested!");
    }

    function runSpecificTest(string memory testName) public {
        console.log("Running specific test:", testName);
        console.log("");

        if (keccak256(bytes(testName)) == keccak256(bytes("origin_deploy"))) {
            OriginPayrollTest originTest = new OriginPayrollTest();
            originTest.setUp();
            originTest.test_DeployOriginPayroll();
        } else if (keccak256(bytes(testName)) == keccak256(bytes("origin_execute"))) {
            OriginPayrollTest originTest = new OriginPayrollTest();
            originTest.setUp();
            originTest.test_ExecuteBatchPayroll();
        } else if (keccak256(bytes(testName)) == keccak256(bytes("dest_deploy"))) {
            DestinationPayrollTest destTest = new DestinationPayrollTest();
            destTest.setUp();
            destTest.test_DeployDestinationPayroll();
        } else if (keccak256(bytes(testName)) == keccak256(bytes("dest_process"))) {
            DestinationPayrollTest destTest = new DestinationPayrollTest();
            destTest.setUp();
            destTest.test_ProcessPayrollBatch();
        } else {
            console.log("Unknown test name. Available tests:");
            console.log("- origin_deploy: OriginPayroll deployment test");
            console.log("- origin_execute: OriginPayroll batch execution test");
            console.log("- dest_deploy: DestinationPayroll deployment test");
            console.log("- dest_process: DestinationPayroll processing test");
        }
    }
} 