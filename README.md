# Sweepstakes Contract 2

This the NFT contract for MoonDAO's second astronaut sweepstakes. The contract uses the ERC721A standard.

### Minting / Claiming
Minting is done through payment of MOONEY (an ERC20 Token). Users will have to approve the contract to spend the amount of 
MOONEY needed to mint the desired amount of NFTs before calling the mint function.

We will also allow entrants of the previous sweepstakes to claim one NFT for free. The whitelist of previous entrants is handled via MerkleProof.

Wallets will be capped to 50 NFTs and there is no cap on the total supply of NFTs.

To comply with our sweepstakes rules, mail in entires will be minted NFTs via the ownerMint function that is only accessible to the contract owner.

### Transfers
Transfer of the NFT will be blocked until the winners are selected.

### Selection Mechanism
10 winners will be selected in descending order with the 10th place winner being selected first and the 1st place winner being selected last.
To select each winner a random number will be generated with a Chainlink VRF. The NFT id that corresponds to the random number is selected as 
the winner and will be stored in the contract. The selection is done by calling the chooseWinner function that is only accessible by the contract owner. 
Ten calls to this function will be done to select all the winners.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
