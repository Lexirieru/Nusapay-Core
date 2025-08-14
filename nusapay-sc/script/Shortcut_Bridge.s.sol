// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {IBridgeTokenSender} from "../src/interfaces/IBridgeTokenSender.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMint} from "../src/interfaces/IMint.sol";

contract ShortcutBridge is Script {
    // *** FILL THIS
    uint256 amount = 50e2;
    address token = 0xCC05F0283a1ce1d8759dc025094a478515586feE;

    // CORE -> ARB
    address bridgeTokenSender = 0x1B7c2e50803F2E8E0181c8CFe63Df42F223DF0Ef;
    address myWallet = 0xBB241303F947f6E223CA400aECEe04693e854b44;
    // ***
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
        // vm.createSelectFork(vm.rpcUrl("arb_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("base_sepolia"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        IMint(token).mint(myWallet, 100e2); 

        IERC20(token).approve(bridgeTokenSender, amount);
        IBridgeTokenSender(bridgeTokenSender).bridge(amount, myWallet, token);
        vm.stopBroadcast();
    }
}
