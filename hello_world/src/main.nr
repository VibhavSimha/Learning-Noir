fn main(x: u64, y: pub u64, z: pub u64) {
    assert(x != y);
    assert(x == z);
}

#[test]
fn test_main() {
    main(1, 2, 1);

    // Uncomment to make test fail
    // main(1, 1);
}
