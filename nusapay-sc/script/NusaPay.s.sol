// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockIDRX} from "../src/mocks/MockIDRX.sol";
import {BridgeTokenSender} from "../src/BridgeTokenSender.sol";
import {BridgeTokenReceiver} from "../src/BridgeTokenReceiver.sol";

contract NusaPayScript is Script {
    MockIDRX public mockIDRX;
    BridgeTokenSender public bridgeTokenSender;
    BridgeTokenReceiver public bridgeTokenReceiver;

    uint256 public ORIGIN_CHAIN_ID = 84532;

    // ***************************** FILL THIS ************************************************************
    uint256 public DESTINATION_CHAIN_ID = 1114;

    address public ORIGIN_mailbox = 0xFBD43c6039f8EB2eE6C2Cc3CD2DAAE985E564508;
    address public ORIGIN_interchainGasPaymaster = 0xff0A4f733B2cF5f8C7869e42f3D92f54226BdE0A;

    address public DESTINATION_mailbox = 0xd5b993dB69c2263086C88870b47eec787b5427B8;
    address public DESTINATION_receiverBridge = 0xe620e02241201F4b5148447BF20D4b6a2EffE026;
    // ****************************************************************************************************

    function setUp() public {
        // ORIGIN chain (core)
        // vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
        vm.createSelectFork(vm.rpcUrl("base_sepolia"));



        // DESTINATION chain
        // vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("op_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("citrea_testnet"));
        // vm.createSelectFork(vm.rpcUrl("bitlayer_testnet"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        if (block.chainid == ORIGIN_CHAIN_ID) {
            // deploy token
            mockIDRX = new MockIDRX();
            // deploy bridgetokensender
            bridgeTokenSender = new BridgeTokenSender(
                ORIGIN_mailbox,
                ORIGIN_interchainGasPaymaster,
                address(mockIDRX),
                DESTINATION_receiverBridge,
                DESTINATION_CHAIN_ID
            );

            console.log("Deployment to", block.chainid);
            console.log("bridgeTokenSender", address(bridgeTokenSender));
            console.log("mockIDRX", address(mockIDRX));
        } else if (block.chainid == DESTINATION_CHAIN_ID) {
            // deploy token
            mockIDRX = new MockIDRX();
            // deploy bridgetokenreceiver
            bridgeTokenReceiver = new BridgeTokenReceiver(DESTINATION_mailbox, address(mockIDRX));

            console.log("Deployment to", block.chainid);
            console.log("bridgeTokenReceiver", address(bridgeTokenReceiver));
            console.log("mockIDRX", address(mockIDRX));
        }
        vm.stopBroadcast();
    }
}

// How it works?
// 1.
// RUN RELAYER
// 2.
// DESTINATION CHAIN
// deploy token
// deploy bridgetokenreceiver
// 3.
// ORIGIN CHAIN
// deploy token
// deploy bridgetokensender
