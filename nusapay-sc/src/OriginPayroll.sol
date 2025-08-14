// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMailbox} from "./interfaces/IMailbox.sol";
import {IInterchainGasPaymaster} from "@hyperlane-xyz/interfaces/IInterchainGasPaymaster.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 * @title OriginPayroll
 * @dev Cross-chain batch payroll contract deployed on Core Testnet (Origin Chain)
 * Handles batch payroll execution and sends cross-chain messages to Base Testnet
 */
contract OriginPayroll is ReentrancyGuard {
    error MailboxNotSet();
    error InterchainGasPaymasterNotSet();
    error DestinationPayrollNotSet();
    error SameChain();
    error NotOwner();
    error InvalidArrayLength();
    error InvalidAmount();
    error InvalidEmployee();
    error InvalidCurrency();
    error InvalidBankAccount();
    error TransferFailed();

    event PayrollBatchSent(
        bytes32 indexed payrollId,
        uint256 totalRecipients,
        uint256 totalCryptoAmount,
        uint256 totalFiatAmount,
        uint256 timestamp
    );

    event PayrollBatchDetails(
        bytes32 indexed payrollId,
        address[] employees,
        uint256[] cryptoAmounts,
        uint256[] fiatAmounts,
        string[] currencies,
        string[] bankAccounts
    );

    address public immutable owner;
    address public mailbox;
    address public interchainGasPaymaster;
    address public destinationPayroll; // Address on Base Testnet
    uint256 public destinationChainId;

    constructor(
        address _mailbox,
        address _interchainGasPaymaster,
        address _destinationPayroll,
        uint256 _destinationChainId
    ) {
        if (_mailbox == address(0)) revert MailboxNotSet();
        if (_interchainGasPaymaster == address(0)) revert InterchainGasPaymasterNotSet();
        if (_destinationPayroll == address(0)) revert DestinationPayrollNotSet();
        if (block.chainid == _destinationChainId) revert SameChain();

        mailbox = _mailbox;
        interchainGasPaymaster = _interchainGasPaymaster;
        destinationPayroll = _destinationPayroll;
        destinationChainId = _destinationChainId;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyMailbox() {
        if (msg.sender != address(mailbox)) revert NotOwner();
        _;
    }

    /**
     * @dev Execute batch payroll for multiple employees
     * @param employees Array of employee addresses on destination chain
     * @param cryptoAmounts Array of USDC amounts to send on-chain
     * @param fiatAmounts Array of fiat amounts for simulation
     * @param currencies Array of fiat currency codes (e.g., "IDR", "USD")
     * @param bankAccounts Array of bank account numbers
     */
    function executePayrollBatch(
        address[] calldata employees,
        uint256[] calldata cryptoAmounts,
        uint256[] calldata fiatAmounts,
        string[] calldata currencies,
        string[] calldata bankAccounts
    ) external payable onlyOwner nonReentrant returns (bytes32 messageId) {
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

        // Generate unique payroll ID
        bytes32 payrollId = keccak256(
            abi.encodePacked(
                block.timestamp,
                msg.sender,
                block.number,
                totalCryptoAmount
            )
        );

        // Encode batch data for cross-chain transmission
        bytes memory messageBody = abi.encode(
            payrollId,
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );

        // Calculate gas payment for Hyperlane
        uint256 gasAmount = IInterchainGasPaymaster(interchainGasPaymaster)
            .quoteGasPayment(uint32(destinationChainId), messageBody.length);

        // Ensure sufficient gas payment
        if (msg.value < gasAmount) {
            revert("Insufficient gas payment");
        }

        // Send cross-chain message
        bytes32 recipientAddress = bytes32(uint256(uint160(destinationPayroll)));
        messageId = IMailbox(mailbox).dispatch{value: gasAmount}(
            uint32(destinationChainId),
            recipientAddress,
            messageBody
        );

        // Emit events
        emit PayrollBatchSent(
            payrollId,
            length,
            totalCryptoAmount,
            totalFiatAmount,
            block.timestamp
        );

        emit PayrollBatchDetails(
            payrollId,
            employees,
            cryptoAmounts,
            fiatAmounts,
            currencies,
            bankAccounts
        );

        return messageId;
    }

    /**
     * @dev Admin function to update Hyperlane configuration
     */
    function setMailbox(address _mailbox) external onlyOwner {
        if (_mailbox == address(0)) revert MailboxNotSet();
        mailbox = _mailbox;
    }

    function setInterchainGasPaymaster(address _interchainGasPaymaster) external onlyOwner {
        if (_interchainGasPaymaster == address(0)) revert InterchainGasPaymasterNotSet();
        interchainGasPaymaster = _interchainGasPaymaster;
    }

    function setDestinationPayroll(address _destinationPayroll) external onlyOwner {
        if (_destinationPayroll == address(0)) revert DestinationPayrollNotSet();
        destinationPayroll = _destinationPayroll;
    }

    /**
     * @dev Emergency function to withdraw excess ETH
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool success, ) = payable(owner).call{value: balance}("");
            if (!success) revert TransferFailed();
        }
    }

    /**
     * @dev Get contract configuration
     */
    function getConfig() external view returns (
        address _mailbox,
        address _interchainGasPaymaster,
        address _destinationPayroll,
        uint256 _destinationChainId
    ) {
        return (mailbox, interchainGasPaymaster, destinationPayroll, destinationChainId);
    }
} 