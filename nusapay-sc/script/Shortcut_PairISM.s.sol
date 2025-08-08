// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

interface IAccountRouter {
    function enrollRemoteRouterAndIsm(uint32 _destinationDomain, bytes32 _router, bytes32 _ism) external;
}

contract ShortcutPairBridgeScript is Script {
    // ******* CORE_TESTNET
    address public CORE_TESTNET_MAILBOX = 0x884523a72A455B533A9c1A07E49a088E34E2AB33;
    uint32 public CORE_TESTNET_DOMAIN = 1114;
    address public CORE_TESTNET_ACCOUNT_ROUTER = 0x9C4C2fdfD583Bd1FCC6387dB6129dE0D9E1B4d4D;
    address public CORE_TESTNET_ISM = 0x970A7cf028456244C7ab6a5F32e88B77B24B3BD6;

    // ******* ARBITRUM_SEPOLIA
    address public CITREA_TESTNET_MAILBOX = 0x850a53a71980B6447E8d34A40094Dd9bDC743e94;
    uint32 public CITREA_TESTNET_DOMAIN = 5115;
    address public CITREA_TESTNET_ACCOUNT_ROUTER = 0x62153FAB3B7F9131D987CBEC8c53d76047Dfdd70;
    address public CITREA_TESTNET_ISM = 0x33b6C9aa2f33088a27CE848b48CC61C379c0197c;

    // ******* DESTINATION_CHAIN_DOMAIN
    // ** Deploy hyperlane on new chain
    address public DESTINATION_CHAIN_MAILBOX = CITREA_TESTNET_MAILBOX;
    uint32 public DESTINATION_CHAIN_DOMAIN = CITREA_TESTNET_DOMAIN;
    address public DESTINATION_CHAIN_ACCOUNT_ROUTER = CITREA_TESTNET_ACCOUNT_ROUTER;
    address public DESTINATION_CHAIN_ISM = CITREA_TESTNET_ISM;

    uint256 public currentChainId = 5115;

    function setUp() public {
        // source chain
        // vm.createSelectFork(vm.rpcUrl("core_testnet"));

        // destination chain
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
        vm.createSelectFork(vm.rpcUrl("citrea_testnet"));
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