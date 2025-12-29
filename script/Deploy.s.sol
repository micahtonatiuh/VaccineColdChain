//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console2} from "forge-std/Script.sol";
import {CustodyAnchor} from "../src/CustodyAnchor.sol";


contract DeployScript is Script {
	function run() external returns (CustodyAnchor) {
		uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

		vm.startBroadcast(deployerPrivateKey);

		CustodyAnchor anchor = new CustodyAnchor();

		console2.log("CustodyAnchor deployed to:", address(anchor));

		vm.stopBroadcast();

		return anchor;

		
	}
}	
