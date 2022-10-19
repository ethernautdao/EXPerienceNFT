// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";
import {EXPerienceNFT} from "src/EXPerienceNFT.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        EXPerienceNFT nftContract = new EXPerienceNFT(
            vm.envAddress("OWNER_ADDR"),
            vm.envAddress("EXP_CONTRACT_ADDR")
        );

        console2.log(
            "Deployed EXPerienceNFT contract at address:",
            address(nftContract)
        );

        vm.stopBroadcast();
    }
}
