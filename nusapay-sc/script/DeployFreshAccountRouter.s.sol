// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

// Import Hyperlane Interchain Account Router
import {InterchainAccountRouter} from "lib/hyperlane-monorepo/solidity/contracts/middleware/InterchainAccountRouter.sol";

contract DeployFreshAccountRouter is Script {
    
    function setUp() public {
        // Set up Core Testnet fork
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
    }

    function run() external {
        console.log("=== Deploying Fresh Account Router ===");
        console.log("Current Chain ID:", block.chainid);
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        
        console.log("Deployer:", deployer);
        
        vm.startBroadcast(privateKey);
        
        // Deploy fresh Interchain Account Router
        InterchainAccountRouter freshAccountRouter = new InterchainAccountRouter();
        
        vm.stopBroadcast();
        
        console.log("Fresh Account Router deployed at:", address(freshAccountRouter));
        console.log("Owner:", freshAccountRouter.owner());
        console.log("");
        console.log("Next steps:");
        console.log("1. Update Shortcut_PayrollEnrollment.s.sol with new Account Router address");
        console.log("2. Run enrollment script with fresh Account Router");
        console.log("3. Test payroll execution");
        console.log("");
        console.log("IMPORTANT: This Account Router has never been enrolled before!");
    }
} 