# Learning Noir

## Requirements

Install the required Barretenberg version:

```bash
bbup -v 5.1.0
````

Install Nargo by running this in your terminal:

```
curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash
noirup
```


This installs noirup, the installation script, and runs it to install the latest version of Nargo.

Verify that you are using the required Noir version:

```bash
nargo --version
```

Expected minimum version:

```text
nargo version = 1.0.0-beta.26
```

---

## Executing the project

Change directory into your `hello_world` project:

```bash
cd hello_world
```

### Generate a `Prover.toml` input file for specifying input values

```bash
nargo check
```

This command generates a `Prover.toml` file that hosts input values to be used when executing your Noir program.

### Specify valid values in the `Prover.toml` file, for example:

```toml
x = 1
y = 2
```

### Then compile and execute your Noir program:

```bash
nargo execute
```

### This command:

* Compiles the Noir program into the `target/hello_world.json` circuit.
* Executes the Noir program with the specified inputs and generates the `target/hello_world.gz` witness.

Both are used when proving your Noir program.

---

## Proving the execution

```bash
bb prove -b ./target/hello_world.json -w ./target/hello_world.gz --write_vk -o target
```

This command:

* Proves the valid execution of your Noir program and generates the zero-knowledge proof at `target/proof`.
* Generates the verification key at `target/vk`.

Both are used when verifying your proof.

---

## Verifying the proof

Verify your proof:

```bash
bb verify -p ./target/proof -k ./target/vk
```

This command verifies the validity of the zero-knowledge proof and returns a success message if valid.

In typical workflows, the prover who generates the proof and the verifier who verifies the proof are usually two different parties. The verifier can verify the validity of the prover's proof without knowing the prover's private inputs, hence zero-knowledge.

