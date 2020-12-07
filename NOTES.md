## Arbitrum deployment notes

Arbitrum validators offer an Ethereum RPC API for their own chain. The state of the chain can be queried from this API and products like Metamask seem to work out of the box. Existing block explorers can likely be connected. It would be interesting if a url like `https://rinkeby.etherscan.io/tx/0xf7c6cd8a61c56a19c0f7e1c515d887d2e8ea61a112ebcd05a2edd546add852e0` resolved with a label indicating this is a transaction from the rollup at X address.

The batching of transactions and operation of the rollup contracts are a bit more opaque. The validator puts some output in the terminal but it's difficult to parse without knowing the codebase. There may be value in exposing who submitted which batch of transactions and what transactions are included. This would be a good jumping off point for a rollup explorer UI.
