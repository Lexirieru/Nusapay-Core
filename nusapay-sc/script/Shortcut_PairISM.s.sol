// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

interface IAccountRouter {
    function enrollRemoteRouterAndIsm(uint32 _destinationDomain, bytes32 _router, bytes32 _ism) external;
}

contract ShortcutPairBridgeScript is Script {
    // ******* CORE_TESTNET
    address public CORE_TESTNET_MAILBOX = 0x9742b159089D7626B63a31011e8f9ed485e7C0DF;
    uint32 public CORE_TESTNET_DOMAIN = 1114;
    address public CORE_TESTNET_ACCOUNT_ROUTER = 0xC8f07759937E7AC9053054E6c87C0f8548DBAa6B;
    address public CORE_TESTNET_ISM = 0x71255D53FA7C96011DCd2503c0857a99c60a9bF9;

    // ******* ARBITRUM_SEPOLIA
    address public ARB_SEPOLIA_MAILBOX = 0x9EF2854894C0436cB4107f6dc43ee82b7cB1DB6D;
    uint32 public ARB_SEPOLIA_DOMAIN = 421614;
    address public ARB_SEPOLIA_ACCOUNT_ROUTER = 0x29Fc20a600B2392b8b659CBD47eAcA44F9Fb71B0;
    address public ARB_SEPOLIA_ISM = 0x4a52F0EeE5395D16DD7872678f402AA57D639969;

    // ******* DESTINATION_CHAIN_DOMAIN
    // ** Deploy hyperlane on new chain
    address public DESTINATION_CHAIN_MAILBOX = ARB_SEPOLIA_MAILBOX;
    uint32 public DESTINATION_CHAIN_DOMAIN = ARB_SEPOLIA_DOMAIN;
    address public DESTINATION_CHAIN_ACCOUNT_ROUTER = ARB_SEPOLIA_ACCOUNT_ROUTER;
    address public DESTINATION_CHAIN_ISM = ARB_SEPOLIA_ISM;

    uint256 public currentChainId = 421614;

    function setUp() public {
        // source chain
        // vm.createSelectFork(vm.rpcUrl("core_testnet"));

        // destination chain
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
        vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
    }

    function run() public payable {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        if (block.chainid == CORE_TESTNET_DOMAIN) {
            IAccountRouter(CORE_TESTNET_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                uint32(DESTINATION_CHAIN_DOMAIN),
                bytes32(uint256(uint160(DESTINATION_CHAIN_ACCOUNT_ROUTER))),
                bytes32(uint256(uint160(DESTINATION_CHAIN_ISM)))
            );
            console.log("Enrolled remote router and ism are successfully on source chain:", block.chainid);
        } else if (block.chainid == DESTINATION_CHAIN_DOMAIN) {
            IAccountRouter(DESTINATION_CHAIN_ACCOUNT_ROUTER).enrollRemoteRouterAndIsm(
                uint32(CORE_TESTNET_DOMAIN),
                bytes32(uint256(uint160(CORE_TESTNET_ACCOUNT_ROUTER))),
                bytes32(uint256(uint160(CORE_TESTNET_ISM)))
            );
            console.log("Enrolled remote router and ism are successfully on destination chain:", block.chainid);
        }
        vm.stopBroadcast();
    }

    // RUN and verify
    // forge script ShortcutPairBridgeScript --verify --broadcast -vvv
    // forge script ShortcutPairBridgeScript --broadcast -vvv
}

// Warp Route config is valid, writing to file undefined: