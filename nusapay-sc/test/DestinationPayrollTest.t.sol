// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DestinationPayrollBatch} from "../src/DestinationPayrollBatch.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MockUSDC} from "../src/mocks/MockUSDC.sol";
import {MockIDRX} from "../src/mocks/MockIDRX.sol";

/**
 * @title DestinationPayrollTest
 * @dev Unit tests for DestinationPayrollBatch contract on Base Sepolia
 * Test scenario: Processing payroll payments for Alice, Bob, and Charlie
 */
contract DestinationPayrollTest is Test {
    // Chain IDs
    uint256 public constant CORE_CHAIN_ID = 1114;
    uint256 public constant BASE_CHAIN_ID = 84532;

    // Hyperlane addresses
    address public constant BASE_MAILBOX = 0xd5b993dB69c2263086C88870b47eec787b5427B8;

    // Test addresses
    address public axel = address(0x1111111111111111111111111111111111111111); // Company A owner
    address public alice = address(0x2222222222222222222222222222222222222222); // Employee 1
    address public bob = address(0x3333333333333333333333333333333333333333);   // Employee 2
    address public charlie = address(0x4444444444444444444444444444444444444444); // Employee 3

    // Contract instances
    DestinationPayrollBatch public destinationPayroll;
    MockUSDC public mockUSDC;
    MockIDRX public mockIDRX;

    // Test data
    address[] public employees;
    uint256[] public cryptoAmounts;
    uint256[] public fiatAmounts;
    string[] public currencies;
    string[] public bankAccounts;

    // Initial balances
    uint256 public constant CONTRACT_INITIAL_BALANCE = 4500e6; // 4500 USDC
    uint256 public constant ALICE_SALARY = 1000e6;  // 1000 USDC
    uint256 public constant BOB_SALARY = 2000e6;    // 2000 USDC
    uint256 public constant CHARLIE_SALARY = 1500e6; // 1500 USDC

    function setUp() public {
        // Set up for Base Sepolia
        vm.createSelectFork(vm.rpcUrl("base_sepolia"));
        
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

        // Deploy mock tokens
        mockUSDC = new MockUSDC();
        mockIDRX = new MockIDRX();
        
        // Mint USDC to Axel for funding the contract (6 decimals)
        mockUSDC.mint(axel, 10000e6); // 10,000 USDC
        
        // Mint IDRX to Axel (2 decimals)
        mockIDRX.mint(axel, 1500000e2); // 15,000,000 IDRX
        
        // Give ETH to Axel for gas payments
        vm.deal(axel, 100 ether);
    }

    function test_DeployDestinationPayroll() public {
        vm.startPrank(axel);
        
        // Deploy DestinationPayrollBatch
        destinationPayroll = new DestinationPayrollBatch(
            BASE_MAILBOX,
            address(mockUSDC)
        );
        
        vm.stopPrank();
        
        // Verify deployment
        assertEq(destinationPayroll.owner(), axel, "Axel should be the owner");
        assertEq(destinationPayroll.mailbox(), BASE_MAILBOX, "Mailbox should be set correctly");
        assertEq(destinationPayroll.usdcToken(), address(mockUSDC), "USDC token should be set correctly");
        
        console.log("DestinationPayrollBatch deployed successfully on Base Sepolia");
        console.log("Address:", address(destinationPayroll));
    }

    function test_ProcessPayrollBatch() public {
        // Setup: Deploy contract
        test_DeployDestinationPayroll();
        
        // Fund the destination contract with USDC
        vm.startPrank(axel);
        mockUSDC.transfer(address(destinationPayroll), CONTRACT_INITIAL_BALANCE);
        vm.stopPrank();
        
        // Verify destination contract has sufficient balance
        assertEq(mockUSDC.balanceOf(address(destinationPayroll)), CONTRACT_INITIAL_BALANCE, "Destination contract should have 4500 USDC");
        
        // Simulate the cross-chain message processing
        bytes memory messageBody = abi.encode(
            keccak256("test_payroll_id"), // payrollId
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        // Mock the Hyperlane mailbox call
        vm.prank(BASE_MAILBOX);
        destinationPayroll.handle(
            1114, // origin chain ID (Core Testnet)
            bytes32(uint256(uint160(address(0x1234567890123456789012345678901234567890)))), // sender (OriginPayroll)
            messageBody
        );
        
        // Verify payments were processed
        assertEq(mockUSDC.balanceOf(alice), ALICE_SALARY, "Alice should receive 1000 USDC");
        assertEq(mockUSDC.balanceOf(bob), BOB_SALARY, "Bob should receive 2000 USDC");
        assertEq(mockUSDC.balanceOf(charlie), CHARLIE_SALARY, "Charlie should receive 1500 USDC");
        
        // Verify destination contract balance is now zero
        assertEq(mockUSDC.balanceOf(address(destinationPayroll)), 0, "Destination contract should have 0 USDC after processing");
        
        console.log("Payroll processing completed successfully!");
        console.log("Alice received:", mockUSDC.balanceOf(alice), "USDC");
        console.log("Bob received:", mockUSDC.balanceOf(bob), "USDC");
        console.log("Charlie received:", mockUSDC.balanceOf(charlie), "USDC");
    }

    function test_ReplayProtection() public {
        // Setup: Deploy and process payroll
        test_ProcessPayrollBatch();
        
        // Fund the contract again
        vm.startPrank(axel);
        mockUSDC.transfer(address(destinationPayroll), CONTRACT_INITIAL_BALANCE);
        vm.stopPrank();
        
        // Try to process the same payroll ID again
        bytes memory messageBody = abi.encode(
            keccak256("test_payroll_id"), // Same payroll ID
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        // This should revert due to replay protection
        vm.prank(BASE_MAILBOX);
        vm.expectRevert("Payroll already processed");
        destinationPayroll.handle(
            1114,
            bytes32(uint256(uint160(address(0x1234567890123456789012345678901234567890)))),
            messageBody
        );
        
        console.log("Replay protection test passed!");
    }

    function test_ValidationChecks() public {
        // Setup: Deploy contract
        test_DeployDestinationPayroll();
        
        // Fund the contract
        vm.startPrank(axel);
        mockUSDC.transfer(address(destinationPayroll), CONTRACT_INITIAL_BALANCE);
        vm.stopPrank();
        
        // Test 1: Invalid array lengths
        address[] memory invalidEmployees = new address[](2);
        invalidEmployees[0] = alice;
        invalidEmployees[1] = bob;
        
        bytes memory invalidMessage = abi.encode(
            keccak256("invalid_payroll_id"),
            invalidEmployees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.prank(BASE_MAILBOX);
        vm.expectRevert(); // Should revert due to array length mismatch
        destinationPayroll.handle(1114, bytes32(0), invalidMessage);
        
        // Test 2: Zero amounts
        uint256[] memory zeroAmounts = new uint256[](3);
        zeroAmounts[0] = 0;
        zeroAmounts[1] = 2000e6;
        zeroAmounts[2] = 1500e6;
        
        bytes memory zeroMessage = abi.encode(
            keccak256("zero_payroll_id"),
            employees,
            zeroAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.prank(BASE_MAILBOX);
        vm.expectRevert(); // Should revert due to zero amount
        destinationPayroll.handle(1114, bytes32(0), zeroMessage);
        
        console.log("All validation checks passed!");
    }

    function test_AccessControl() public {
        // Setup: Deploy contract
        test_DeployDestinationPayroll();
        
        // Test: Non-mailbox cannot call handle function
        address nonMailbox = address(0x9999999999999999999999999999999999999999);
        
        bytes memory messageBody = abi.encode(
            keccak256("access_test_payroll_id"),
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.prank(nonMailbox);
        vm.expectRevert(); // Should revert due to access control
        destinationPayroll.handle(1114, bytes32(0), messageBody);
        
        console.log("Access control test passed!");
    }

    function test_EventEmission() public {
        // Setup: Deploy contract
        test_DeployDestinationPayroll();
        
        // Fund the contract
        vm.startPrank(axel);
        mockUSDC.transfer(address(destinationPayroll), CONTRACT_INITIAL_BALANCE);
        vm.stopPrank();
        
        // Process payroll and capture events
        bytes memory messageBody = abi.encode(
            keccak256("event_test_payroll_id"),
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        // Expect events to be emitted
        vm.expectEmit(true, true, false, true);
        emit SalaryPaid(keccak256("event_test_payroll_id"), alice, ALICE_SALARY, block.timestamp);
        
        vm.expectEmit(true, true, false, true);
        emit FiatPaymentSimulated(keccak256("event_test_payroll_id"), alice, fiatAmounts[0], "IDR", "BCA 1234567890", block.timestamp);
        
        vm.prank(BASE_MAILBOX);
        destinationPayroll.handle(
            1114,
            bytes32(uint256(uint160(address(0x1234567890123456789012345678901234567890)))),
            messageBody
        );
        
        console.log("Event emission test passed!");
    }

    function test_InsufficientBalance() public {
        // Setup: Deploy contract
        test_DeployDestinationPayroll();
        
        // Fund the contract with insufficient balance
        vm.startPrank(axel);
        mockUSDC.transfer(address(destinationPayroll), 1000e6); // Only 1000 USDC instead of 4500
        vm.stopPrank();
        
        // Try to process payroll
        bytes memory messageBody = abi.encode(
            keccak256("insufficient_balance_payroll_id"),
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.prank(BASE_MAILBOX);
        vm.expectRevert(); // Should revert due to insufficient balance
        destinationPayroll.handle(
            1114,
            bytes32(uint256(uint160(address(0x1234567890123456789012345678901234567890)))),
            messageBody
        );
        
        console.log("Insufficient balance test passed!");
    }

    // Declare events for testing
    event SalaryPaid(
        bytes32 indexed payrollId,
        address indexed employee,
        uint256 cryptoAmount,
        uint256 timestamp
    );

    event FiatPaymentSimulated(
        bytes32 indexed payrollId,
        address indexed employee,
        uint256 fiatAmount,
        string currency,
        string bankAccount,
        uint256 timestamp
    );
} 