// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {IBridgeTokenSender} from "../src/interfaces/IBridgeTokenSender.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMint} from "../src/interfaces/IMint.sol";

contract ShortcutBridge is Script {
    // *** FILL THIS
    uint256 amount = 50e2;
    address token = 0xD5B6d15dcDfCF954C2a84664a73e990cefe9C03D;

    // CORE -> ARB
    address bridgeTokenSender = 0x17E52AEA0dC9eB8795Ee314b927208158c8867bB;
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
