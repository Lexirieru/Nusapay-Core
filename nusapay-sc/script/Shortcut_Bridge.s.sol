// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {IBridgeTokenSender} from "../src/interfaces/IBridgeTokenSender.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMint} from "../src/interfaces/IMint.sol";

contract ShortcutBridge is Script {
    // *** FILL THIS
    uint256 amount = 10e2;
    address token = 0x4C1cA3C06ff0AFA986B68FF4C75b3357E6AB0D2A;

    // CORE -> ARB
    address bridgeTokenSender = 0xC9479F89fA8fcb9035A97e83B7Ae2A232f7560fc;
    address myWallet = 0xa5ea1Cb1033F5d3BD207bF6a2a2504cF1c3e9F42;
    // ***
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("core_testnet"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        IMint(token).mint(myWallet, 20e2);

        IERC20(token).approve(bridgeTokenSender, amount);
        IBridgeTokenSender(bridgeTokenSender).bridge(amount, myWallet, token);
        vm.stopBroadcast();
    }
}
