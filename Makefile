-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ANVIL_KEY_2 := 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
DEFAULT_ANVIL_ADDRESS := 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
DEFAULT_ANVIL_ADDRESS_2 := 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

AIRDROP_ADDRESS := 0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f #make sure to update this at deployment
TOKEN_ADDRESS := 0x322813Fd9A801c5507c9de605d63CEA4f2CE6c44 #make sure to update this at deployment

# zkSync constants

ROOT := 0x474d994c58e37b12085fdb7bc6bbcd046cf1907b90de3b7fb083cf3636c8ebfb
PROOF_1 := 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad
PROOF_2 := 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f
AIRDROP_AMOUNT := 25000000000000000000

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make fund ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install

# Update Dependencies
update:; forge update

build:; forge build


test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1


NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop $(NETWORK_ARGS)


# Generate Merkle Tree input file
generate :; forge script script/GenerateInput.s.sol:GenerateInput

# Make Merkle Root and Proofs
make :; forge script script/MakeMerkle.s.sol:MakeMerkle

# Generate input and output files 

merkle :; forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle


sign :; 
	@cast wallet sign --no-hash --private-key $(DEFAULT_ANVIL_KEY) ${shell cast call ${AIRDROP_ADDRESS} "getMessageHash(address,uint256)" ${DEFAULT_ANVIL_ADDRESS} ${AIRDROP_AMOUNT} --rpc-url http://localhost:8545}

claim:;
	@forge script script/Interactions.s.sol:ClaimAirdrop --sender ${DEFAULT_ANVIL_ADDRESS_2} --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_2) --broadcast

balance :; 
	@cast --to-dec ${shell cast call ${TOKEN_ADDRESS} "balanceOf(address)" ${DEFAULT_ANVIL_ADDRESS} --rpc-url http://localhost:8545} 