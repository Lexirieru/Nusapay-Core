// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {IBridgeTokenSender} from "../src/interfaces/IBridgeTokenSender.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMint} from "../src/interfaces/IMint.sol";

contract ShortcutBridge is Script {
    // *** FILL THIS
    uint256 amount = 10e2;
    address token = address(0);

    // CORE -> ARB
    address bridgeTokenSender = address(0);
    address myWallet = 0xFA128bBD1846c19025c7428AEE403Fc06F0A9e38;
    // ***
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        // IMint(token).mint(myWallet, 20e2);

        IERC20(token).approve(bridgeTokenSender, amount);
        IBridgeTokenSender(bridgeTokenSender).bridge(amount, myWallet, token);
        vm.stopBroadcast();
    }
}
