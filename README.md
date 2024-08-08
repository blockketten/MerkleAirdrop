# Merkle Airdrop With Account Abstraction For Claims
## Overview

This repository contains smart contracts for a Merkle tree-based airdrop system. The smart contracts and scripts are written in Solidity, using the Foundry toolchain. The design allows for efficient and gas-optimized token distribution to a large number of recipients. The system uses Merkle proofs to verify claim eligibility and incorporates signature verification for added security. EIP-721 signatures enable account abstraction, in the form of gasless, sponsored airdrop claim transactions that are executed by a 3rd party. This design can be used with any arbitrary ERC-20 token. The current implementation is only designed for use on a local Anvil network; further development is required to make this work on a live testnet/mainnet. 


## Table of Contents

- [Merkle Airdrop With Account Abstraction For Claims](#merkle-airdrop-with-account-abstraction-for-claims)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Deployment and Execution on Anvil](#deployment-and-execution-on-anvil)
    - [Testing](#testing)
  - [Future Improvements](#future-improvements)
  - [License](#license)

## Getting Started

These instructions will help you set up the project on your local machine for development and testing purposes.

### Prerequisites

- [Foundry](https://book.getfoundry.sh/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installation

Clone the repository and install the necessary dependencies:

```bash
git clone https://github.com/blockketten/MerkleAirdrop.git
cd MerkleAirdrop
make install
```
### Deployment and Execution on Anvil

To deploy on the Anvil local network:

1. Open a second terminal and pass 

```bash
anvil
```
to initiate a local Anvil network

2. Return to the first terminal and pass

```bash
make deploy
```

The make file contains all the values and logic to deploy the contracts on the Anvil network without any further input.

3. Copy and paste both the address of the airdrop distribution contract and the ERC-20 token contract, found in the terminal output, into the AIRDROP_ADDRESS := and TOKEN_ADDRESS := fields of the Makefile

4. In the terminal, pass
```bash
make merkle
```
to populate the input.json and output.json files

5. In the terminal, pass
```bash
make sign
```
Copy and paste the generated signature, sans the "0x" at the beginning, into the Interactions.s.sol script as the SIGNATURE value. 

6. 
In the terminal, pass
```bash
make claim
```
The second default Anvil address will send the claim transaction on behalf of the first Anvil address, using the signature as verification that it has authorization to do so.

### Testing

The contracts in this repo are tested with a variety of unit and fuzz tests. The fuzz tests have an accompying handler script, to ensure that the fuzz testing performed is useful.

To run the tests, use the following command:

```bash
forge test
```

## Future Improvements

This system is only designed for deployment and use on an Anvil local network; more development is required to make this useable on a live testnet/mainnet. 

Importation of roots, proofs, addresses, and signatures into the contracts and scripts should be automated.

The system should be automated and modular to the point that any arbitrary list of addresses of any length could be imported as the list of potential claimants. 

Testing coverage should be improved by writing more tests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
