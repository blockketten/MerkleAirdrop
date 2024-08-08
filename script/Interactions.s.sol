// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdrop__InvalidSignatureLength();

    // Constant address that will claim the airdrop
    address private constant CLAIMING_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // Constant amount of tokens to claim (25 tokens with 18 decimals)
    uint256 private constant AMOUNT_TO_CLAIM = 25 * 1e18;

    // Constants for Merkle proof hashes
    bytes32 private constant PROOF1 =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    // Array of Merkle proof hashes
    bytes32[] private proof = [PROOF1, PROOF2];

    // Signature for the claim (65 bytes: r (32 bytes) + s (32 bytes) + v (1 byte))
    bytes SIGNATURE =
        hex"e5166eb6391c463d791df68820404d18aabef21abea2c83fd875aaf0c64daf03387a274ffa2c29c3675c5a999adf7e9e24667167e4c954adfc4e87c9b5c83f511c";

    // Main function to run the script
    function run() external {
        // Get the address of the most recently deployed MerkleAirdrop contract
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        // Call the claimAirdrop function with the deployed contract address
        claimAirdrop(mostRecentlyDeployed);
    }

    // Function to claim the airdrop
    function claimAirdrop(address airdrop) public {
        // Start broadcasting transactions
        vm.startBroadcast();
        // Split the signature into v, r, s components
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(SIGNATURE);
        // Call the claim function on the MerkleAirdrop contract
        MerkleAirdrop(airdrop).claim(
            CLAIMING_ADDRESS,
            AMOUNT_TO_CLAIM,
            proof,
            v,
            r,
            s
        );
        // Stop broadcasting transactions
        vm.stopBroadcast();
        // Log that the airdrop has been claimed
        console.log("Airdrop claimed");
    }

    // Internal function to split the signature into its components
    function _splitSignature(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        // Check if the signature length is correct (65 bytes)
        if (sig.length != 65) {
            revert ClaimAirdrop__InvalidSignatureLength();
        }
        // Use assembly to efficiently extract r, s, and v from the signature
        assembly {
            // Load 32 bytes (r) starting from position 32 in memory
            r := mload(add(sig, 32))
            // Load 32 bytes (s) starting from position 64 in memory
            s := mload(add(sig, 64))
            // Load 1 byte (v) starting from position 96 in memory
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
