fn main(guessHash: Field, answerHash: pub Field) {
    assert(guessHash == answerHash);
}



#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}
