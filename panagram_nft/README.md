# ZK Panagram

- Each "answer" (guess to the panagram) is a "round"
- The owner is the only person that can start a new round
- The round needs to have a minimum duration
- There needs to be a "winenr" to start the next round
- The contract needs to be an NFT contract
    - ERC-1155 (token id 0 for winners, token id 1 for runners up)
    - Mint ID 0 if the user is the first person to guess correctly
    - Mint ID 1 if the user is the second person to guess correctly
- To check if the user's guess is correct, we will call the Verifier smart contract