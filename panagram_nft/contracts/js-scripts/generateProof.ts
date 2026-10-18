import { Noir } from "@noir-lang/noir_js";
import { ethers } from "ethers";
import { Barretenberg, UltraHonkBackend } from "@aztec/bb.js";
import { fileURLToPath } from "url";
import path from "path";
import fs from "fs";

const FIELD_MODULUS =
21888242871839275222246405745257275088548364400416034343698204186575808495617n;

function sha256ToField(hash: string): string {
    const normalizedHash = hash.startsWith("0x")
    ? hash
    : `0x${hash}`;
    
    return (BigInt(normalizedHash) % FIELD_MODULUS).toString();
}
// Disable console.log for solidity ffi input
console.log = () => { };


// get the circuit file with the bytecode
const circuitPath = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../circuits/target/panagram_nft.json");
console.log("Circuit Path:", circuitPath);

const circuitData = JSON.parse(fs.readFileSync(circuitPath, "utf-8"));

const bytecode = circuitData.bytecode;
console.log("Bytecode:", bytecode);
// initialize Noir with the circuit
export default async function generateProof() {
    // initialize the backend with the bytecode
    // create inputs
    // execute circuit with inputs to create witness
    // generate proof (using the backend) with the witness
    // return proof
    console.log("Generating proof...");
    const guessHash = process.argv[2];
    const answerHash = process.argv[3];
    console.log("Guess Hash:", guessHash);
    console.log("Answer Hash:", answerHash);
    
    try {
        const noir = new Noir(circuitData);
        const inputs = {
            // guessHash: sha256ToField(guessHash),
            guessHash: guessHash,
            // answerHash: sha256ToField(answerHash)
            answerHash: answerHash
        };
        const api = await Barretenberg.new();
        const backend = new UltraHonkBackend(bytecode, api);
        const { witness } = await noir.execute(inputs);
        const { proof } = await backend.generateProof(witness, { verifierTarget: "evm" });

        // ABI encode the proof for Solidity
        const proofData = ethers.AbiCoder.defaultAbiCoder().encode(["bytes"], [proof]);
        return proofData;
    }
    catch (error) {
        console.error("Error generating proof:", error);
        throw error;
    }
}

async function main() {
        generateProof().then((proofData) => {
            process.stdout.write(proofData);
            process.exit(0);
        }).catch((error) => {
            console.error("Error:", error);
            process.exit(1);
        }); 
}
void main();