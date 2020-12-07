const readline = require('readline')
const Web3 = require('web3')
require('dotenv/config')

// Test script for looking at arbitrum node data

;(async () => {
  let nodeUrl = `http://localhost:8547`
  nodeUrl = (await getInput(`Enter an Arbitrum node url (${nodeUrl}): `)) || nodeUrl

  const web3 = new Web3(new Web3.providers.HttpProvider(nodeUrl))
  // It doesn't cost money to deploy on an Arbitrum chain so any private key works
  const account = web3.eth.accounts.create()
  web3.eth.accounts.wallet.add(account.privateKey)

  let blockNumber = await web3.eth.getBlockNumber()
  while (blockNumber > 0) {
    const block = await web3.eth.getBlock(blockNumber, true)
    if (block.transactions.length) {
      console.log(block)
    }
    blockNumber--
  }
})()

async function getInput(prompt) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: true,
  })
  const answer = await new Promise(rs => rl.question(prompt, rs))
  rl.close()
  return answer
}
