// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";
import {EXPerienceNFT} from "src/EXPerienceNFT.sol";
import {EXPerienceRenderer} from "src/libs/EXPerienceRenderer.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console2.log("Deploying from address", vm.addr(deployerPrivateKey));

        EXPerienceRenderer renderer = new EXPerienceRenderer();
        console2.log("EXPerienceRenderer:", address(renderer));

        EXPerienceNFT nftContract = new EXPerienceNFT(
            vm.envAddress("OWNER_ADDR"),
            vm.envAddress("EXP_CONTRACT_ADDR"),
            address(renderer)
        );

        console2.log("EXPerienceNFT:", address(nftContract));

        vm.stopBroadcast();
    }
}
