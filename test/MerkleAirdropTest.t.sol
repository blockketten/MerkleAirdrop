// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {GibToken} from "src/GibToken.sol";

contract MerkleAirdropTest is Test {
    GibToken public token;
    MerkleAirdrop public airdrop;

    bytes32 public ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;

    bytes32 proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address user;
    uint256 userPrivKey;
    address public gasPayer;

    function setUp() public {
        token = new GibToken();
        airdrop = new MerkleAirdrop(ROOT, token);
        token.mint(token.owner(), AMOUNT_TO_SEND);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        uint256 startingUserBalance = token.balanceOf(user);
        console.log("startingUserBalance", startingUserBalance);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest); // sign the message

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s); // gas payer calls claim, using the signed message

        uint256 endingUserBalance = token.balanceOf(user);
        console.log("endingUserBalance", endingUserBalance);
        assertEq(endingUserBalance, startingUserBalance + AMOUNT_TO_CLAIM);
    }
}
