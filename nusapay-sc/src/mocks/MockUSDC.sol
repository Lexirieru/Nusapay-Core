// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockUSDC
 * @dev Mock USDC token with 6 decimals for testing
 */
contract MockUSDC is ERC20 {
    uint8 private constant DECIMALS = 6;
    
    constructor() ERC20("Mock USDC", "USDC") {}
    
    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }
    
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
    
    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
} 