// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IVerifier} from "./Verifier.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Panagram is ERC1155, Ownable {
    IVerifier public s_verifier;

    uint256 public constant MIN_DURATION = 10800; // 3 hours in seconds
    uint256 public s_roundStartTime;
    address public s_currentRoundWinner;
    uint256 public s_currentRound= 0;
    bytes32 public s_answer;
    mapping (address => uint256) public s_lastCorrectGuessRound;

    // Events
    event  Panagram__VerifierUpdated(IVerifier verifier);
    event Panagram__NewRoundStarted(bytes32 answer);
    event Panagram__WinnerCrowned(address indexed winner, uint256 round);
    event Panagram__RunnerUpCrowned(address indexed runnerUp, uint256 indexed round);

    // Errors
    error Panagram__MinTimeNotPassed(uint256 minDuration, uint256 timeElapsed);
    error Panagram__NoRoundWinner();
    error Panagram__FirstPanagramNotSet();
    error Panagram__AlreadyGuessedCorrectly(uint256 round, address user);
    error Panagram__InvalidProof();

    constructor(IVerifier _verifier) ERC1155("ipfs::/bafybeickwrzs7onlfvc3oxmfht4bweorsrkoekxziurxkxoavmisblpeni/{id}.json") Ownable(msg.sender) {
        s_verifier = _verifier;
    }

    // function to create a new round
    function newRound(bytes32 _answer) external onlyOwner {
       
        if(s_roundStartTime == 0) {
            s_roundStartTime = block.timestamp;
            s_answer = _answer;
        } else {
            if(s_roundStartTime + MIN_DURATION > block.timestamp) {
                revert Panagram__MinTimeNotPassed(MIN_DURATION, block.timestamp - s_roundStartTime);
            } 
            if(s_currentRoundWinner == address(0)){
                revert Panagram__NoRoundWinner();
            }
            // Reset
            s_roundStartTime = block.timestamp;
            s_currentRoundWinner = address(0);
            s_answer = _answer;
        }
        s_currentRound++;
        emit Panagram__NewRoundStarted(_answer);
    }

    // function to allow a user to submit a guess
    function makeGuess(bytes memory proof) external returns (bool){
        // check whether the first rond is started
        if(s_currentRound == 0) {
            revert Panagram__FirstPanagramNotSet();
        }

        // check if the user has already guessed correctly
        if(s_lastCorrectGuessRound[msg.sender] == s_currentRound) {
            revert Panagram__AlreadyGuessedCorrectly(s_currentRound, msg.sender);
        }

        // check the proof and verify it with the Verifier contract
        bytes32[] memory publicInputs = new bytes32[](1);
        publicInputs[0] = s_answer;
        bool proofResult = s_verifier.verify(proof, publicInputs);
        if(!proofResult) {
            // revert if incorrect
            revert Panagram__InvalidProof();
        }
        s_lastCorrectGuessRound[msg.sender] = s_currentRound;
        // if correct, check if they are first, if they then mint NFT ID 0
        if(s_currentRoundWinner == address(0)) {
            s_currentRoundWinner = msg.sender;
            _mint(msg.sender, 0, 1, "");
            emit Panagram__WinnerCrowned(msg.sender, s_currentRound);
        } else {
            // if correct and not first, mint NFT ID 1
            _mint(msg.sender, 1, 1, "");
            emit Panagram__RunnerUpCrowned(msg.sender, s_currentRound);
        }
        return proofResult;
    }
    // set a new verifier
    function SetVerifier(IVerifier _verifier) external onlyOwner{
        s_verifier = _verifier;
        emit Panagram__VerifierUpdated(_verifier);
    }
}