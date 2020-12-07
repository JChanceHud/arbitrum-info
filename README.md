# Arbitrum Research

This repo contains everything needed to deploy an Arbitrum rollup chain.

Use of this repo requires node, yarn, and docker.

## Rinkeby Addresses

Deployed globals:

```
ArbRollup deployed at 0xE5390d6142076e9E2f853bC24442dda46919a9A3
GlobalInbox deployed at 0x4CAF699D7a468ea81869d768896DA4D3562855Ec
InboxTopChallenge deployed at 0x8c6AAfB2c59723E183C6ABb2b39521431a919e98
ExecutionChallenge deployed at 0x232B92df338e989306C32A62997bE697061C4F10
OneStepProof deployed at 0xdf9A11B38610f241aD9B457f7283b4EfC22BE858
ChallengeFactory deployed at 0x7a2DF520b69105ABA53456eAff834554C563E835
ArbFactory deployed at 0x78D2d992bcfBCd0905603284C83248E5B14378e2
```

Deployed Arbitrum rollup:

```
0x3e58DD2f508fa7E30B8E226B6fC42C86fAD3f610
```

Parameters:

```
Stake Requirement (Eth): 0.01
Grace Period (minutes): 180
Speed Limit: 1.0
Max Assertion Size (seconds): 50
```

## Scripts

Below is a description of the scripts included in this repo.

#### Deploy

`npm run deploy`

Deploys the Arbitrum global contracts such as `RollupFactory` and `GlobalInbox`. Should not need to be executed more than once. The global addresses above can be reused for all rollups on the chain.

#### Deploy Rollup

`npm run deploy:rollup`

Starts a webserver and opens a webpage for deploying an Arbitrum rollup.

#### Start Validator

`npm run start:validator`

Starts an Arbitrum transaction aggregator and validator. Starts an Arbitrum server on port 8547. This server exposes a standard Eth RPC API. Transaction costs are executed with a gas price of 0.

Create an Arbitrum rollup using `npm run deploy:rollup` or supply the following address when asked: `0x3e58DD2f508fa7E30B8E226B6fC42C86fAD3f610`.

On first launch the following will appear:

```sh
arb-tx-aggregator_1  | 2020/12/05 19:15:01 arb-tx-aggregator.go:78: Launching aggregator for chain 0x4e20ec7b9b90790e527ce404efd8876ff6f0dcf6 with chain id 148914954099958
arb-validator1_1     | 2020/12/05 19:15:04 balance.go:39: Waiting for account 0x554854e2cb30d00381ffb068ad7fcf7a3f95567e to receive ETH
arb-tx-aggregator_1  | 2020/12/05 19:15:04 arb-tx-aggregator.go:90: Aggregator submitting batches from address [144 16 168 17 194 255 124 71 144 71 116 252 181 44 221 97 117 191 210 9]
arb-tx-aggregator_1  | 2020/12/05 19:15:04 balance.go:39: Waiting for account 0x9010a811c2ff7c47904774fcb52cdd6175bfd209 to receive ETH
```

Send the stake amount plus a small additional amount of Ether for transaction fees to the supplied addresses. (`0x554854e2cb30d00381ffb068ad7fcf7a3f95567e` and `0x9010a811c2ff7c47904774fcb52cdd6175bfd209` in the above example)

Once the transaction completes the validator will begin syncing the rollup and accept transactions on port 8547.

#### Deploy Contract

`npm run deploy:contract`

Compiles and deploys a simple contract to an Arbitrum chain. Run this command after `start:validator`.

The contract in question is a bank supporting deposits, transfers, and withdrawals. (See `contracts/BankVault.sol`)

#### Start Bank

`npm run start:bank`

Starts a webapp for interacting with the BankVault contract on the Arbitrum chain.

To use the app open `http://localhost:8080` in an browser with Metamask installed.

## Configuring Metamask

Arbitrum exposes a pseudo-eth RPC api. To interact using Metmask go to Settings -> Networks -> Add Network.

Name the network "Arbitrum" or similar, and add the following settings:

```
RPC URL: http://localhost:8547
Chain ID: 48958245434896
Currency Symbol: ETH
```

Note: These settings assume a local Arbitrum validator using the rollup at `0x3e58DD2f508fa7E30B8E226B6fC42C86fAD3f610`.
