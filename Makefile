-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ANVIL_KEY_2 := 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
DEFAULT_ANVIL_ADDRESS := 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
DEFAULT_ANVIL_ADDRESS_2 := 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

AIRDROP_ADDRESS := 0xc5a5C42992dECbae36851359345FE25997F5C42d #make sure to update this at deployment
TOKEN_ADDRESS := 0x09635F643e140090A9A8Dcd712eD6285858ceBef #make sure to update this at deployment


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

install :; forge install cyfrin/foundry-devops@0.1.0 --no-commit && forge install dmfxyz/murky --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit

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