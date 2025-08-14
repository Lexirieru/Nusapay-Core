// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {OriginPayroll} from "../src/OriginPayroll.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MockUSDC} from "../src/mocks/MockUSDC.sol";
import {MockIDRX} from "../src/mocks/MockIDRX.sol";

/**
 * @title OriginPayrollTest
 * @dev Unit tests for OriginPayroll contract on Core Testnet
 * Test scenario: Axel from Company A executes batch payroll
 */
contract OriginPayrollTest is Test {
    // Chain IDs
    uint256 public constant CORE_CHAIN_ID = 1114;
    uint256 public constant BASE_CHAIN_ID = 84532;

    // Hyperlane addresses
    address public constant CORE_MAILBOX = 0xFBD43c6039f8EB2eE6C2Cc3CD2DAAE985E564508;
    address public constant CORE_IGP = 0xff0A4f733B2cF5f8C7869e42f3D92f54226BdE0A;

    // Test addresses
    address public axel = address(0x1111111111111111111111111111111111111111); // Company A owner
    address public alice = address(0x2222222222222222222222222222222222222222); // Employee 1
    address public bob = address(0x3333333333333333333333333333333333333333);   // Employee 2
    address public charlie = address(0x4444444444444444444444444444444444444444); // Employee 3

    // Contract instances
    OriginPayroll public originPayroll;
    MockUSDC public mockUSDC;
    MockIDRX public mockIDRX;

    // Test data
    address[] public employees;
    uint256[] public cryptoAmounts;
    uint256[] public fiatAmounts;
    string[] public currencies;
    string[] public bankAccounts;

    // Initial balances
    uint256 public constant AXEL_INITIAL_BALANCE = 4500e6; // 4500 USDC
    uint256 public constant ALICE_SALARY = 1000e6;  // 1000 USDC
    uint256 public constant BOB_SALARY = 2000e6;    // 2000 USDC
    uint256 public constant CHARLIE_SALARY = 1500e6; // 1500 USDC

    function setUp() public {
        // Set up for Core Testnet
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
        
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
        
        // Mint initial USDC to Axel (6 decimals)
        mockUSDC.mint(axel, AXEL_INITIAL_BALANCE);
        
        // Mint IDRX to Axel (2 decimals)
        mockIDRX.mint(axel, 1500000e2); // 15,000,000 IDRX
        
        // Give ETH to Axel for gas payments
        vm.deal(axel, 100 ether);
        
        // Verify Axel has the correct balances
        assertEq(mockUSDC.balanceOf(axel), AXEL_INITIAL_BALANCE, "Axel should have 4500 USDC initially");
        assertEq(mockIDRX.balanceOf(axel), 1500000e2, "Axel should have 15,000,000 IDRX initially");
        assertEq(axel.balance, 100 ether, "Axel should have 100 ETH for gas");
    }

    function test_DeployOriginPayroll() public {
        vm.startPrank(axel);
        
        // Deploy OriginPayroll with placeholder destination address
        originPayroll = new OriginPayroll(
            CORE_MAILBOX,
            CORE_IGP,
            address(0x1234567890123456789012345678901234567890), // Placeholder address
            BASE_CHAIN_ID
        );
        
        vm.stopPrank();
        
        // Verify deployment
        assertEq(originPayroll.owner(), axel, "Axel should be the owner");
        assertEq(originPayroll.mailbox(), CORE_MAILBOX, "Mailbox should be set correctly");
        assertEq(originPayroll.interchainGasPaymaster(), CORE_IGP, "IGP should be set correctly");
        assertEq(originPayroll.destinationChainId(), BASE_CHAIN_ID, "Destination chain ID should be set correctly");
        
        console.log("OriginPayroll deployed successfully on Core Testnet");
        console.log("Address:", address(originPayroll));
    }

    function test_ExecuteBatchPayroll() public {
        // Setup: Deploy contract
        test_DeployOriginPayroll();
        
        // Verify Axel's initial balance
        assertEq(mockUSDC.balanceOf(axel), AXEL_INITIAL_BALANCE, "Axel should have 4500 USDC");
        
        // Calculate total salary
        uint256 totalSalary = ALICE_SALARY + BOB_SALARY + CHARLIE_SALARY;
        assertEq(totalSalary, 4500e6, "Total salary should be 4500 USDC");
        
        // Execute batch payroll
        vm.startPrank(axel);
        
        // Estimate gas payment (for testing purposes)
        uint256 gasPayment = 0.01 ether;
        
        // Execute the batch payroll
        bytes32 messageId = originPayroll.executePayrollBatch{value: gasPayment}(
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.stopPrank();
        
        // Verify message was sent
        assertTrue(messageId != bytes32(0), "Message ID should not be zero");
        
        console.log("Batch payroll executed successfully!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("Total employees:", employees.length);
        console.log("Total salary:", totalSalary);
        console.log("Alice salary:", ALICE_SALARY);
        console.log("Bob salary:", BOB_SALARY);
        console.log("Charlie salary:", CHARLIE_SALARY);
    }

    function test_ValidationChecks() public {
        // Setup: Deploy contract
        test_DeployOriginPayroll();
        
        // Test 1: Invalid array lengths
        address[] memory invalidEmployees = new address[](2);
        invalidEmployees[0] = alice;
        invalidEmployees[1] = bob;
        uint256[] memory validAmounts = new uint256[](3);
        validAmounts[0] = 1000e6;
        validAmounts[1] = 2000e6;
        validAmounts[2] = 1500e6;
        
        // Give ETH to Axel for gas payments
        vm.deal(axel, 100 ether);
        
        vm.startPrank(axel);
        vm.expectRevert(); // Should revert due to array length mismatch
        originPayroll.executePayrollBatch{value: 0.01 ether}(
            invalidEmployees,
            validAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        vm.stopPrank();
        
        // Test 2: Zero amounts
        uint256[] memory zeroAmounts = new uint256[](3);
        zeroAmounts[0] = 0;
        zeroAmounts[1] = 2000e6;
        zeroAmounts[2] = 1500e6;
        
        vm.startPrank(axel);
        vm.expectRevert(); // Should revert due to zero amount
        originPayroll.executePayrollBatch{value: 0.01 ether}(
            employees,
            zeroAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        vm.stopPrank();
        
        // Test 3: Invalid employee address
        address[] memory invalidAddresses = new address[](3);
        invalidAddresses[0] = address(0);
        invalidAddresses[1] = bob;
        invalidAddresses[2] = charlie;
        
        vm.startPrank(axel);
        vm.expectRevert(); // Should revert due to invalid address
        originPayroll.executePayrollBatch{value: 0.01 ether}(
            invalidAddresses,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        vm.stopPrank();
        
        console.log("All validation checks passed!");
    }

    function test_AccessControl() public {
        // Setup: Deploy contract
        test_DeployOriginPayroll();
        
        // Test: Non-owner cannot execute payroll
        address nonOwner = address(0x9999999999999999999999999999999999999999);
        
        // Give ETH to non-owner for gas payments
        vm.deal(nonOwner, 10 ether);
        
        vm.startPrank(nonOwner);
        vm.expectRevert(); // Should revert due to access control
        originPayroll.executePayrollBatch{value: 0.01 ether}(
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        vm.stopPrank();
        
        console.log("Access control test passed!");
    }

    function test_EventEmission() public {
        // Setup: Deploy contract
        test_DeployOriginPayroll();
        
        // Execute batch payroll and capture events
        vm.startPrank(axel);
        
        // Expect events to be emitted
        vm.expectEmit(true, false, false, true);
        emit PayrollBatchSent(
            bytes32(0), // We don't know the exact payrollId, so we use 0
            3, // totalRecipients
            4500e6, // totalCryptoAmount
            67500000, // totalFiatAmount
            block.timestamp
        );
        
        bytes32 messageId = originPayroll.executePayrollBatch{value: 0.01 ether}(
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );
        
        vm.stopPrank();
        
        console.log("Event emission test passed!");
        console.log("Message ID:", vm.toString(messageId));
    }

    // Declare events for testing
    event PayrollBatchSent(
        bytes32 indexed payrollId,
        uint256 totalRecipients,
        uint256 totalCryptoAmount,
        uint256 totalFiatAmount,
        uint256 timestamp
    );
} 