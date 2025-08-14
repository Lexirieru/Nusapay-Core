// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMessageRecipient} from "@hyperlane-xyz/interfaces/IMessageRecipient.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DestinationPayrollBatch
 * @dev Cross-chain batch payroll contract deployed on Base Testnet (Destination Chain)
 * Receives batch payroll data from Core Testnet and processes USDC payments + fiat simulation
 */
contract DestinationPayrollBatch is IMessageRecipient, ReentrancyGuard {
    error MailboxNotSet();
    error NotMailbox();
    error InvalidArrayLength();
    error InvalidAmount();
    error InvalidEmployee();
    error InvalidCurrency();
    error InvalidBankAccount();
    error TransferFailed();
    error InsufficientBalance();

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

    event PayrollBatchProcessed(
        bytes32 indexed payrollId,
        uint256 totalEmployees,
        uint256 totalCryptoAmount,
        uint256 totalFiatAmount,
        uint256 timestamp
    );

    address public immutable owner;
    address public mailbox;
    address public usdcToken; // USDC testnet token on Base

    // Track processed payrolls to prevent replay attacks
    mapping(bytes32 => bool) public processedPayrolls;

    constructor(address _mailbox, address _usdcToken) {
        if (_mailbox == address(0)) revert MailboxNotSet();
        if (_usdcToken == address(0)) revert MailboxNotSet();

        mailbox = _mailbox;
        usdcToken = _usdcToken;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotMailbox();
        _;
    }

    modifier onlyMailbox() {
        if (msg.sender != address(mailbox)) revert NotMailbox();
        _;
    }

    /**
     * @dev Handle incoming cross-chain message from Hyperlane
     * @param _origin Origin chain ID (Core Testnet)
     * @param _sender Sender address on origin chain
     * @param _messageBody Encoded batch payroll data
     */
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _messageBody
    ) external override onlyMailbox nonReentrant {
        // Decode the batch payroll data
        (
            bytes32 payrollId,
            address[] memory employees,
            uint256[] memory cryptoAmounts,
            uint256[] memory fiatAmounts,
            string[] memory currencies,
            string[] memory bankAccounts
        ) = abi.decode(_messageBody, (bytes32, address[], uint256[], uint256[], string[], string[]));

        // Prevent replay attacks
        if (processedPayrolls[payrollId]) {
            revert("Payroll already processed");
        }

        // Validate array lengths
        uint256 length = employees.length;
        if (length == 0) revert InvalidArrayLength();
        if (cryptoAmounts.length != length) revert InvalidArrayLength();
        if (fiatAmounts.length != length) revert InvalidArrayLength();
        if (currencies.length != length) revert InvalidArrayLength();
        if (bankAccounts.length != length) revert InvalidArrayLength();

        // Validate inputs
        uint256 totalCryptoAmount = 0;
        uint256 totalFiatAmount = 0;

        for (uint256 i = 0; i < length; i++) {
            if (employees[i] == address(0)) revert InvalidEmployee();
            if (cryptoAmounts[i] == 0) revert InvalidAmount();
            if (fiatAmounts[i] == 0) revert InvalidAmount();
            if (bytes(currencies[i]).length == 0) revert InvalidCurrency();
            if (bytes(bankAccounts[i]).length == 0) revert InvalidBankAccount();

            totalCryptoAmount += cryptoAmounts[i];
            totalFiatAmount += fiatAmounts[i];
        }

        // Check if contract has sufficient USDC balance
        if (IERC20(usdcToken).balanceOf(address(this)) < totalCryptoAmount) {
            revert InsufficientBalance();
        }

        // Mark payroll as processed
        processedPayrolls[payrollId] = true;

        // Process payments for each employee
        for (uint256 i = 0; i < length; i++) {
            address employee = employees[i];
            uint256 cryptoAmount = cryptoAmounts[i];
            uint256 fiatAmount = fiatAmounts[i];
            string memory currency = currencies[i];
            string memory bankAccount = bankAccounts[i];

            // Transfer USDC to employee
            bool transferSuccess = IERC20(usdcToken).transfer(employee, cryptoAmount);
            if (!transferSuccess) revert TransferFailed();

            // Emit salary paid event
            emit SalaryPaid(
                payrollId,
                employee,
                cryptoAmount,
                block.timestamp
            );

            // Emit fiat payment simulation event (for UI demo)
            emit FiatPaymentSimulated(
                payrollId,
                employee,
                fiatAmount,
                currency,
                bankAccount,
                block.timestamp
            );
        }

        // Emit batch completion event
        emit PayrollBatchProcessed(
            payrollId,
            length,
            totalCryptoAmount,
            totalFiatAmount,
            block.timestamp
        );
    }

    /**
     * @dev Admin function to update configuration
     */
    function setMailbox(address _mailbox) external onlyOwner {
        if (_mailbox == address(0)) revert MailboxNotSet();
        mailbox = _mailbox;
    }

    function setUsdcToken(address _usdcToken) external onlyOwner {
        if (_usdcToken == address(0)) revert MailboxNotSet();
        usdcToken = _usdcToken;
    }

    /**
     * @dev Emergency function to withdraw USDC (only owner)
     */
    function emergencyWithdrawUsdc(uint256 _amount) external onlyOwner {
        if (_amount > 0) {
            bool success = IERC20(usdcToken).transfer(owner, _amount);
            if (!success) revert TransferFailed();
        }
    }

    /**
     * @dev Emergency function to withdraw ETH (only owner)
     */
    function emergencyWithdrawEth() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool success, ) = payable(owner).call{value: balance}("");
            if (!success) revert TransferFailed();
        }
    }

    /**
     * @dev Check if a payroll has been processed
     */
    function isPayrollProcessed(bytes32 _payrollId) external view returns (bool) {
        return processedPayrolls[_payrollId];
    }

    /**
     * @dev Get contract configuration
     */
    function getConfig() external view returns (
        address _mailbox,
        address _usdcToken
    ) {
        return (mailbox, usdcToken);
    }

    /**
     * @dev Get USDC balance of this contract
     */
    function getUsdcBalance() external view returns (uint256) {
        return IERC20(usdcToken).balanceOf(address(this));
    }

    /**
     * @dev Receive function to accept ETH (for gas payments)
     */
    receive() external payable {}
} 