fn main(guessHash: Field, answerHash: pub Field, address: pub Field) {
    assert(guessHash == answerHash);
}



#[test]
fn test_main() {
    main(1, 2, 6);

    // Uncomment to make test fail
    // main(1, 1);
}
