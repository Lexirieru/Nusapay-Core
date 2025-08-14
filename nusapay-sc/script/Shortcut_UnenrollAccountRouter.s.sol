// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

interface IAccountRouter {
    function enrollRemoteRouterAndIsm(uint32 _destinationDomain, bytes32 _router, bytes32 _ism) external;
    function unenrollRemoteRouter(uint32 _destinationDomain) external;
    function getRemoteRouter(uint32 _destinationDomain) external view returns (bytes32);
    function getRemoteIsm(uint32 _destinationDomain) external view returns (bytes32);
    function owner() external view returns (address);
}

contract Shortcut_UnenrollAccountRouter is Script {
    
    // ******* CORE_TESTNET
    address public CORE_TESTNET_ACCOUNT_ROUTER = 0xC064B2c9a6CC6c5cB82aA614e7763ceB4aC3268C;
    uint32 public CORE_TESTNET_DOMAIN = 1114;
    
    // ******* BASE_SEPOLIA
    address public BASE_SEPOLIA_ACCOUNT_ROUTER = 0x7a4F96F5Cd091A4908a70337a0084c606adC15b4;
    uint32 public BASE_SEPOLIA_DOMAIN = 84532;
    
    // ******* PAYROLL CONTRACTS
    address public ORIGIN_PAYROLL = 0x3C81e05806A86A215814A85D1323f371D15E72B4; // Core Testnet (NEW)
    address public DESTINATION_PAYROLL = 0x6AA1115b8faE8DB3B2547B22b54fdf5657c26A27; // Base Sepolia (OLD - Need to deploy new one)

    function setUp() public {
        // Uncomment the chain you want to work on
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
    }

    function run() public payable {
        console.log("=== NusaPay Account Router Unenrollment Script ===");
        console.log("Current Chain ID:", block.chainid);
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            console.log("Unenrolling on Core Testnet (1114)...");
            
            // Unenroll from Base Sepolia
            IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).unenrollRemoteRouter(BASE_SEPOLIA_DOMAIN);
            console.log("Unenrolled from Base Sepolia successfully!");
            
        } else if (block.chainid == BASE_SEPOLIA_DOMAIN) {
            console.log("Unenrolling on Base Sepolia (84532)...");
            
            // Unenroll from Core Testnet
            IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).unenrollRemoteRouter(CORE_TESTNET_DOMAIN);
            console.log("Unenrolled from Core Testnet successfully!");
        }
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== Unenrollment Summary ===");
        console.log("Core Testnet Domain:", CORE_TESTNET_DOMAIN);
        console.log("Base Sepolia Domain:", BASE_SEPOLIA_DOMAIN);
        console.log("OriginPayroll:", ORIGIN_PAYROLL);
        console.log("DestinationPayroll:", DESTINATION_PAYROLL);
        console.log("");
        console.log("Unenrollment completed!");
    }
    
    function checkEnrollmentStatus() external view {
        console.log("=== Checking Enrollment Status ===");
        console.log("Current Chain ID:", block.chainid);
        
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            console.log("Checking Core Testnet Account Router...");
            console.log("Account Router Address:", CORE_TESTNET_ACCOUNT_ROUTER);
            
            address owner = IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).owner();
            console.log("Account Router Owner:", owner);
            console.log("Your Address:", vm.addr(vm.envUint("PRIVATE_KEY")));
            
            try IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).getRemoteRouter(BASE_SEPOLIA_DOMAIN) returns (bytes32 remoteRouter) {
                console.log("Remote Router (Base Sepolia):", vm.toString(remoteRouter));
                
                if (remoteRouter == bytes32(0)) {
                    console.log("Status: UNENROLLED from Base Sepolia");
                } else {
                    console.log("Status: ENROLLED to Base Sepolia");
                    console.log("Enrolled Router Address:", address(uint160(uint256(remoteRouter))));
                }
            } catch {
                console.log("Status: ERROR - Could not get remote router");
                console.log("This might mean the domain is not enrolled or there's an issue with the contract");
            }
            
            try IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).getRemoteIsm(BASE_SEPOLIA_DOMAIN) returns (bytes32 remoteIsm) {
                console.log("Remote ISM (Base Sepolia):", vm.toString(remoteIsm));
            } catch {
                console.log("Remote ISM: ERROR - Could not get remote ISM");
            }
            
        } else if (block.chainid == BASE_SEPOLIA_DOMAIN) {
            console.log("Checking Base Sepolia Account Router...");
            console.log("Account Router Address:", BASE_SEPOLIA_ACCOUNT_ROUTER);
            
            address owner = IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).owner();
            console.log("Account Router Owner:", owner);
            console.log("Your Address:", vm.addr(vm.envUint("PRIVATE_KEY")));
            
            try IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).getRemoteRouter(CORE_TESTNET_DOMAIN) returns (bytes32 remoteRouter) {
                console.log("Remote Router (Core Testnet):", vm.toString(remoteRouter));
                
                if (remoteRouter == bytes32(0)) {
                    console.log("Status: UNENROLLED from Core Testnet");
                } else {
                    console.log("Status: ENROLLED to Core Testnet");
                    console.log("Enrolled Router Address:", address(uint160(uint256(remoteRouter))));
                }
            } catch {
                console.log("Status: ERROR - Could not get remote router");
                console.log("This might mean the domain is not enrolled or there's an issue with the contract");
            }
            
            try IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).getRemoteIsm(CORE_TESTNET_DOMAIN) returns (bytes32 remoteIsm) {
                console.log("Remote ISM (Core Testnet):", vm.toString(remoteIsm));
            } catch {
                console.log("Remote ISM: ERROR - Could not get remote ISM");
            }
        }
    }
    
    function enrollWithNewAddresses() external {
        console.log("=== Enrolling Account Router with New Addresses ===");
        console.log("Current Chain ID:", block.chainid);
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            console.log("Enrolling on Core Testnet (1114)...");
            console.log("New OriginPayroll:", ORIGIN_PAYROLL);
            console.log("New DestinationPayroll:", DESTINATION_PAYROLL);
            
            // Enroll to Base Sepolia with new addresses
            IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                BASE_SEPOLIA_DOMAIN,
                bytes32(uint256(uint160(DESTINATION_PAYROLL))),
                bytes32(uint256(uint160(0xdC29BFB593E9Fd013a9B096159f282c551a88B00))) // Base Sepolia ISM
            );
            console.log("Enrolled to Base Sepolia successfully!");
            
        } else if (block.chainid == BASE_SEPOLIA_DOMAIN) {
            console.log("Enrolling on Base Sepolia (84532)...");
            console.log("New OriginPayroll:", ORIGIN_PAYROLL);
            console.log("New DestinationPayroll:", DESTINATION_PAYROLL);
            
            // Enroll to Core Testnet with new addresses
            IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                CORE_TESTNET_DOMAIN,
                bytes32(uint256(uint160(ORIGIN_PAYROLL))),
                bytes32(uint256(uint160(0x4f1534C12Bf15D3e1e6621E7cd6fa8B06da5635b))) // Core Testnet ISM
            );
            console.log("Enrolled to Core Testnet successfully!");
        }
        
        vm.stopBroadcast();
        
        console.log("Enrollment with new addresses completed!");
    }
    
    function reenroll() external {
        console.log("=== Re-enrolling Account Router ===");
        console.log("Current Chain ID:", block.chainid);
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            console.log("Re-enrolling on Core Testnet (1114)...");
            
            // Re-enroll to Base Sepolia
            IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                BASE_SEPOLIA_DOMAIN,
                bytes32(uint256(uint160(DESTINATION_PAYROLL))),
                bytes32(uint256(uint160(0xdC29BFB593E9Fd013a9B096159f282c551a88B00))) // Base Sepolia ISM
            );
            console.log("Re-enrolled to Base Sepolia successfully!");
            
        } else if (block.chainid == BASE_SEPOLIA_DOMAIN) {
            console.log("Re-enrolling on Base Sepolia (84532)...");
            
            // Re-enroll to Core Testnet
            IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                CORE_TESTNET_DOMAIN,
                bytes32(uint256(uint160(ORIGIN_PAYROLL))),
                bytes32(uint256(uint160(0x4f1534C12Bf15D3e1e6621E7cd6fa8B06da5635b))) // Core Testnet ISM
            );
            console.log("Re-enrolled to Core Testnet successfully!");
        }
        
        vm.stopBroadcast();
        
        console.log("Re-enrollment completed!");
    }
}

// Usage:
// 1. Unenroll from Core Testnet: forge script script/Shortcut_UnenrollAccountRouter.s.sol:Shortcut_UnenrollAccountRouter --sig "run()" --rpc-url core_testnet --broadcast
// 2. Unenroll from Base Sepolia: forge script script/Shortcut_UnenrollAccountRouter.s.sol:Shortcut_UnenrollAccountRouter --sig "run()" --rpc-url base_sepolia --broadcast
// 3. Check status: forge script script/Shortcut_UnenrollAccountRouter.s.sol:Shortcut_UnenrollAccountRouter --sig "checkEnrollmentStatus()" --rpc-url core_testnet
// 4. Re-enroll: forge script script/Shortcut_UnenrollAccountRouter.s.sol:Shortcut_UnenrollAccountRouter --sig "reenroll()" --rpc-url core_testnet --broadcast 