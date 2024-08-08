// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {GibToken} from "src/GibToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    // Merkle root for the airdrop, precomputed off-chain
    bytes32 private s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    // Amount of tokens to transfer to the airdrop contract (4 * 25 tokens with 18 decimals)
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    // Function to deploy MerkleAirdrop and GibToken contracts
    function deployMerkleAirdrop() public returns (MerkleAirdrop, GibToken) {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy a new GibToken contract
        GibToken token = new GibToken();

        // Deploy a new MerkleAirdrop contract, passing the Merkle root and the address of the GibToken
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(address(token))
        );

        // Mint tokens to the sender (deployer) of this script
        token.mint(msg.sender, s_amountToTransfer);

        // Transfer the minted tokens from the deployer to the airdrop contract
        token.transfer(address(airdrop), s_amountToTransfer);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Return the deployed MerkleAirdrop and GibToken contracts
        return (airdrop, token);
    }

    // Main function to run the script
    function run() external returns (MerkleAirdrop, GibToken) {
        // Call deployMerkleAirdrop and return its result
        return deployMerkleAirdrop();
    }
}
