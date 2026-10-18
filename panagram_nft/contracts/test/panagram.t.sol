// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Panagram} from "../src/panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test {
    HonkVerifier public verifier;
    Panagram public panagram;
    address user = makeAddr("user");
    uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32 ANSWER = bytes32(uint256(keccak256("deadbeef")) % FIELD_MODULUS);

    // deploy the verifier
    // deploy the panagram contract
    // create the answer
    // start the round
    function setUp() public {
        verifier = new HonkVerifier();
        panagram = new Panagram(verifier);
        panagram.newRound(ANSWER);
    }

    function _getProof(bytes32 guess, bytes32 correctAnswer) internal returns (bytes memory _proof) {
        // generate the proof using the Noir circuit
        uint256 NUMBER_ARGS = 5;
        string[] memory inputs = new string[](NUMBER_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);
        bytes memory encodedProof = vm.ffi(
            inputs
        );
        _proof = abi.decode(encodedProof, (bytes));
        console.logBytes(_proof);
        return _proof;
    }

    // 1. Test someone recieves NFT 0 if they guess correctly first
    function testCorrectGuessPasses() public {
        vm.prank(user);
        panagram.makeGuess(_getProof(ANSWER, ANSWER));
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        vm.prank(user);
        vm.expectRevert();
        panagram.makeGuess(_getProof(ANSWER, ANSWER));
    }
    // 2. Test someone recieves NFT 1 if they guess correctly second
    // 3. Test we can start a new round
}