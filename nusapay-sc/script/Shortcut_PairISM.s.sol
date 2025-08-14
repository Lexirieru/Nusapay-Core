// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

interface IAccountRouter {
    function enrollRemoteRouterAndIsm(uint32 _destinationDomain, bytes32 _router, bytes32 _ism) external;
}

contract ShortcutPairBridgeScript is Script {
    // ******* CORE_TESTNET
    address public CORE_TESTNET_MAILBOX = 0xd5b993dB69c2263086C88870b47eec787b5427B8;
    uint32 public CORE_TESTNET_DOMAIN = 1114;
    address public CORE_TESTNET_ACCOUNT_ROUTER = 0x4eAD9ce51e740277ac070ec84914dE614D20036c;
    address public CORE_TESTNET_ISM = 0x92F716054dd0dD9aa8939A220022B275f090758a;

    // ******* BASE_SEPOLIA
    address public BASE_SEPOLIA_MAILBOX = 0xFBD43c6039f8EB2eE6C2Cc3CD2DAAE985E564508;
    uint32 public BASE_SEPOLIA_DOMAIN = 84532;
    address public BASE_SEPOLIA_ACCOUNT_ROUTER = 0xff0A4f733B2cF5f8C7869e42f3D92f54226BdE0A;
    address public BASE_SEPOLIA_ISM = 0x7a2Beacdfc0FA044264CF103500Fe6eD15193b58;

    // ******* DESTINATION_CHAIN_DOMAIN
    // ** Deploy hyperlane on new chain
    address public DESTINATION_CHAIN_MAILBOX = BASE_SEPOLIA_MAILBOX;
    uint32 public DESTINATION_CHAIN_DOMAIN = BASE_SEPOLIA_DOMAIN;
    address public DESTINATION_CHAIN_ACCOUNT_ROUTER = BASE_SEPOLIA_ACCOUNT_ROUTER;
    address public DESTINATION_CHAIN_ISM = BASE_SEPOLIA_ISM;

    uint256 public currentChainId = 84532;

    function setUp() public {
        // source chain
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));


        // destination chain
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("citrea_testnet"));
        // vm.createSelectFork(vm.rpcUrl("bitlayer_testnet"));
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