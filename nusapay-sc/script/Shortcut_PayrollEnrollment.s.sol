// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

interface IAccountRouter {
    function enrollRemoteRouterAndIsm(uint32 _destinationDomain, bytes32 _router, bytes32 _ism) external;
    function getRemoteRouter(uint32 _destinationDomain) external view returns (bytes32);
    function getRemoteIsm(uint32 _destinationDomain) external view returns (bytes32);
}

contract Shortcut_PayrollEnrollment is Script {
    
    // ******* CORE_TESTNET
    address public CORE_TESTNET_MAILBOX = 0xA948C6025FfCe453e359f72FAfc916F586e0BF26;
    uint32 public CORE_TESTNET_DOMAIN = 1114;
    address public CORE_TESTNET_ACCOUNT_ROUTER = 0x5558306914971922B959bAe5d7A2424FCD40230f;
    address public CORE_TESTNET_ISM = 0xde8D27a0FBF17E3AD2c3A88e0530Bb99E22ED2D6;

    // ******* BASE_SEPOLIA
    address public BASE_SEPOLIA_MAILBOX = 0x80AA79da4F080Dbcdab8609C1A4DA20574A9Aa48;
    uint32 public BASE_SEPOLIA_DOMAIN = 84532;
    address public BASE_SEPOLIA_ACCOUNT_ROUTER = 0x525e7932623f4edf0a2CA85a565e98B70788AF74;
    address public BASE_SEPOLIA_ISM = 0xFCD8a6b6C050C28eCc43E80b13454dedBa5A49EB;

    // ******* PAYROLL CONTRACTS
    address public ORIGIN_PAYROLL = 0x9e2F95f2514B6da2BfD82eb615d867909EFECd4d; // Core Testnet
    address public DESTINATION_PAYROLL = 0x167445859606bd51a9e734503e4708ce7Bd060ac; // Base Sepolia
    
    // ******* TOKEN ADDRESSES
    address public CORE_USDC = 0x9e5967F25211e058fB73D98eB7D315C3c9f85b82; // Core Testnet
    address public CORE_IDRX = 0x36f381aF59D0231B903eFd1F8Fa444B5E082255C; // Core Testnet
    address public BASE_USDC = 0x9206D261BAe50abEFa751624ce6033a0b40Fbc23; // Base Sepolia

    function setUp() public {
        // Uncomment the chain you want to work on
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
    }

    function run() public payable {
        console.log("=== NusaPay Payroll Enrollment Script ===");
        console.log("Current Chain ID:", block.chainid);
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            console.log("Enrolling on Core Testnet (1114)...");
            
            // Enroll OriginPayroll on Core Testnet
            IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                BASE_SEPOLIA_DOMAIN,
                bytes32(uint256(uint160(DESTINATION_PAYROLL))),
                bytes32(uint256(uint160(BASE_SEPOLIA_ISM)))
            );
            console.log("Enrolled OriginPayroll on Core Testnet successfully!");
            console.log("OriginPayroll:", ORIGIN_PAYROLL);
            console.log("DestinationPayroll:", DESTINATION_PAYROLL);
            
        } else if (block.chainid == BASE_SEPOLIA_DOMAIN) {
            console.log("Enrolling on Base Sepolia (84532)...");
            
            // Enroll DestinationPayroll on Base Sepolia
            IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                CORE_TESTNET_DOMAIN,
                bytes32(uint256(uint160(ORIGIN_PAYROLL))),
                bytes32(uint256(uint160(CORE_TESTNET_ISM)))
            );
            console.log("Enrolled DestinationPayroll on Base Sepolia successfully!");
            console.log("OriginPayroll:", ORIGIN_PAYROLL);
            console.log("DestinationPayroll:", DESTINATION_PAYROLL);
        }
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== Enrollment Summary ===");
        console.log("Core Testnet Domain:", CORE_TESTNET_DOMAIN);
        console.log("Base Sepolia Domain:", BASE_SEPOLIA_DOMAIN);
        console.log("OriginPayroll:", ORIGIN_PAYROLL);
        console.log("DestinationPayroll:", DESTINATION_PAYROLL);
        console.log("");
        console.log("Next steps:");
        console.log("1. Run this script on Core Testnet first");
        console.log("2. Then run this script on Base Sepolia");
        console.log("3. Test payroll execution again");
    }
    
    function checkEnrollmentStatus() external view {
        console.log("=== Checking Enrollment Status ===");
        console.log("Current Chain ID:", block.chainid);
        console.log("OriginPayroll:", ORIGIN_PAYROLL);
        console.log("DestinationPayroll:", DESTINATION_PAYROLL);
        console.log("Core Testnet Account Router:", CORE_TESTNET_ACCOUNT_ROUTER);
        console.log("Base Sepolia Account Router:", BASE_SEPOLIA_ACCOUNT_ROUTER);
        console.log("");
        
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            console.log("Checking Core Testnet Account Router...");
            
            try IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).getRemoteRouter(BASE_SEPOLIA_DOMAIN) returns (bytes32 remoteRouter) {
                console.log("Remote Router (Base Sepolia):", vm.toString(remoteRouter));
                
                if (remoteRouter == bytes32(0)) {
                    console.log("Status: NOT ENROLLED to Base Sepolia");
                } else {
                    console.log("Status: ENROLLED to Base Sepolia");
                    console.log("Enrolled Router Address:", address(uint160(uint256(remoteRouter))));
                    
                    if (address(uint160(uint256(remoteRouter))) == DESTINATION_PAYROLL) {
                        console.log("Router address matches!");
                    } else {
                        console.log("Router address mismatch!");
                        console.log("Expected:", DESTINATION_PAYROLL);
                        console.log("Found:", address(uint160(uint256(remoteRouter))));
                    }
                }
            } catch {
                console.log("Status: ERROR - Could not get remote router");
            }
            
            try IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).getRemoteIsm(BASE_SEPOLIA_DOMAIN) returns (bytes32 remoteIsm) {
                console.log("Remote ISM (Base Sepolia):", vm.toString(remoteIsm));
            } catch {
                console.log("Remote ISM: ERROR - Could not get remote ISM");
            }
            
        } else if (block.chainid == BASE_SEPOLIA_DOMAIN) {
            console.log("Checking Base Sepolia Account Router...");
            
            try IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).getRemoteRouter(CORE_TESTNET_DOMAIN) returns (bytes32 remoteRouter) {
                console.log("Remote Router (Core Testnet):", vm.toString(remoteRouter));
                
                if (remoteRouter == bytes32(0)) {
                    console.log("Status: NOT ENROLLED to Core Testnet");
                } else {
                    console.log("Status: ENROLLED to Core Testnet");
                    console.log("Enrolled Router Address:", address(uint160(uint256(remoteRouter))));
                    
                    if (address(uint160(uint256(remoteRouter))) == ORIGIN_PAYROLL) {
                        console.log("Router address matches!");
                    } else {
                        console.log("Router address mismatch!");
                        console.log("Expected:", ORIGIN_PAYROLL);
                        console.log("Found:", address(uint160(uint256(remoteRouter))));
                    }
                }
            } catch {
                console.log("Status: ERROR - Could not get remote router");
            }
            
            try IAccountRouter(BASE_SEPOLIA_ACCOUNT_ROUTER).getRemoteIsm(CORE_TESTNET_DOMAIN) returns (bytes32 remoteIsm) {
                console.log("Remote ISM (Core Testnet):", vm.toString(remoteIsm));
            } catch {
                console.log("Remote ISM: ERROR - Could not get remote ISM");
            }
        }
    }
}

// Usage:
// 1. Enroll on Core Testnet: forge script script/Shortcut_PayrollEnrollment.s.sol:Shortcut_PayrollEnrollment --sig "run()" --rpc-url core_testnet --broadcast
// 2. Enroll on Base Sepolia: forge script script/Shortcut_PayrollEnrollment.s.sol:Shortcut_PayrollEnrollment --sig "run()" --rpc-url base_sepolia --broadcast 