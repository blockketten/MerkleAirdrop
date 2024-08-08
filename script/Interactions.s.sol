// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdrop__InvalidSignatureLength();

    address private constant CLAIMING_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private constant AMOUNT_TO_CLAIM = 25 * 1e18;
    bytes32 private constant PROOF1 =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private proof = [PROOF1, PROOF2];
    bytes SIGNATURE =
        hex"e5166eb6391c463d791df68820404d18aabef21abea2c83fd875aaf0c64daf03387a274ffa2c29c3675c5a999adf7e9e24667167e4c954adfc4e87c9b5c83f511c"; // this is the v, r, s signature. The first 32 bytes are r, the next 32 are s, and the final byte is v

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(
            CLAIMING_ADDRESS,
            AMOUNT_TO_CLAIM,
            proof,
            v,
            r,
            s
        );
        vm.stopBroadcast();
        console.log("Airdrop claimed");
    }

    function _splitSignature(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdrop__InvalidSignatureLength();
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
