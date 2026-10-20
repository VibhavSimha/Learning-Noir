use dep::keccak256::keccak256;

fn main(guessHash: Field, answerHash: pub Field, address: pub Field) {
    let guessHashBytes: [u8; 32] = guessHash.to_be_bytes();
    let guessSecondHash: [u8; 32] = keccak256(guessHashBytes, 32);
    assert(Field::from_be_bytes(guessSecondHash) == answerHash);
}



#[test]
fn test_main() {
    main(1, 2, 6);

    // Uncomment to make test fail
    // main(1, 1);
}
