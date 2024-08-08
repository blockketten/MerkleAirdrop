// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {console} from "forge-std/Script.sol";

// Main contract definition, inheriting from EIP712 for structured data signing
contract MerkleAirdrop is EIP712 {
    // Use SafeERC20 functions for the IERC20 interface
    using SafeERC20 for IERC20;
    // Use ECDSA functions for bytes32 type
    using ECDSA for bytes32;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    // Custom error for invalid Merkle proof
    error MerkleAirdrop__InvalidProof();
    // Custom error for invalid signature
    error MerkleAirdrop__InvalidSignature();
    // Custom error when an account tries to claim more than once
    error MerkleAirdrop__ThisAccountHasAlreadyClaimed();

    /*//////////////////////////////////////////////////////////////
                           TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/

    // Struct to represent an airdrop claim
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    // Array to store addresses of claimers
    address[] claimers;

    // Immutable variable to store the Merkle root
    bytes32 private immutable i_merkleRoot;

    // Immutable variable to store the ERC20 token being airdropped
    IERC20 private immutable i_airdropToken;

    // Mapping to track which addresses have claimed their airdrop
    mapping(address claimer => bool claimed) private s_hasClaimed;

    // Constant hash of the type string for EIP-712 structured data signing
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AidropClaim(address account,uint256 amount)");

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    // Event emitted when a successful claim is made
    event Claimed(address account, uint256 amount);
    // Event emitted if the Merkle root is updated (note: this contract doesn't implement root updates)
    event MerkleRootUpdated(bytes32 newMerkleRoot);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Constructor to initialize the contract with a Merkle root and the airdrop token
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    // Function to claim tokens from the airdrop
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Check if the account has already claimed
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__ThisAccountHasAlreadyClaimed();
        }
        // Calculate the leaf node hash for the Merkle proof
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount))) // hashes twice to prevent collisions and 2nd preimage attacks
        );
        // Verify the Merkle proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Verify the signature
        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Mark the account as having claimed
        s_hasClaimed[account] = true; // prevent double claiming
        // Emit the Claimed event
        emit Claimed(account, amount);
        // Log the claiming account and amount before the transfer
        console.log(
            "Claiming account and balance before claim: ",
            account,
            amount
        );
        // Transfer the tokens to the claiming account
        i_airdropToken.safeTransfer(account, amount);
        // Log the claiming account and amount after the transfer
        console.log(
            "Claiming account and balance after claim: ",
            account,
            amount
        );
    }

    /*//////////////////////////////////////////////////////////////
                     PRIVATE AND INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Internal function to validate the signature
    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        // Attempt to recover the signer's address from the signature
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        // Log the actual signer and the account for debugging
        console.log("actualSigner: ", actualSigner);
        console.log("account: ", account);
        // Check if the recovered signer matches the account
        return actualSigner == account;
    }

    /*//////////////////////////////////////////////////////////////
                   PUBLIC AND EXTERNAL VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Public view function to get the message hash for signing
    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    // External view function to get the Merkle root
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    // External view function to get the airdrop token address
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
