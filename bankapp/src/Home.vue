<template>
  <div>
    <div class="no-metamask" v-if="!metamask">
      Metamask not detected!
    </div>
    <button v-on:click="loadAccounts" v-if="metamask && !connected()">
      Connect Metamask
    </button>
    <div class="account-info">
      <div>Active Rollup: {{ rollupAddress }}</div>
      <div>Bank Contract: {{ bankContractAddress }}</div>
      <div>Current chain ID: {{ chainId }} <span style="font-weight: bold">({{ chainDescription }})</span></div>
      <div>My Address: {{ address }}</div>
      <div>My Bank Balance: {{ balance }} Eth</div>
    </div>
    <div class="action-box">
      <div>Deposit into Arbitrum</div>
      <div class="wrong-network" v-if="+chainId !== 4">
        Connect to a Rinkeby node to deposit
      </div>
      Amount: <input type="text" v-model="arbitrumDepositAmount" />
      <button v-on:click="arbitrumDeposit">Deposit</button>
    </div>
    <div class="action-box">
      <div>Deposit into Bank</div>
      <div class="wrong-network" v-if="+chainId < 100">
        Connect to an Arbitrum node to deposit
      </div>
      Amount: <input type="text" v-model="bankDepositAmount" />
      <button v-on:click="bankDeposit">Deposit</button>
    </div>
    <div class="action-box">
      <div>Transfer</div>
      <div class="wrong-network" v-if="+chainId < 100">
        Connect to an Arbitrum node to transfer
      </div>
      To: <input type="text" v-model="transferAddr" />
      Amount: <input type="text" v-model="transferAmount" />
      <button v-on:click="transfer">Transfer</button>
    </div>
    <div class="action-box">
      <div>Withdraw</div>
      <div class="wrong-network" v-if="+chainId < 100">
        Connect to an Arbitrum node to withdraw
      </div>
      Amount: <input type="text" v-model="withdrawAmount" />
      <button v-on:click="withdraw">Withdraw</button>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import Component from 'vue-class-component'
import Web3 from 'web3'
import GlobalInboxABI from './GlobalInboxABI.json'
import BankABI from './BankABI.json'

@Component({
  name: 'Home',
  components: {},
  metaInfo: {
    title: 'Bank App',
  },
})
export default class Home extends Vue {
  metamask = typeof window.ethereum !== 'undefined'
  rollupAddress = '0x3e58DD2f508fa7E30B8E226B6fC42C86fAD3f610'
  bankContractAddress = '0x876618F3Ff32D437A83f810bE1a978DFD52C33E3'
  balance = 0
  address = ''
  chainId = ''
  chainDescription = ''
  withdrawAmount = ''
  transferAddr = ''
  transferAmount = ''
  arbitrumDepositAmount = ''
  bankDepositAmount = ''

  async mounted() {
    if (!this.metamask) return
    if (window.ethereum.isConnected()) {
      this.chainUpdated(window.ethereum.chainId)
      window.ethereum.on('chainChanged', this.chainUpdated)
      await this.loadAccounts()
      await this.loadBalance()
    }
  }

  chainUpdated(chainId) {
    this.chainDescription = ''
    if (+chainId === 4) {
      this.chainDescription = 'rinkeby'
    } else if (+chainId > 100) {
      this.chainDescription = 'arbitrum'
    }
    this.chainId = +chainId
  }

  connected() {
    return this.metamask && window.ethereum.isConnected()
  }

  async loadAccounts() {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    this.address = accounts[0]
  }

  async loadBalance() {
    const web3 = new Web3(window.ethereum)
    const contract = new web3.eth.Contract(BankABI, this.bankContractAddress)
    const balance = await contract.methods.balance(this.address).call()
    this.balance = web3.utils.fromWei(balance).toString()
    const events = await contract.getPastEvents('allEvents')
  }

  async withdraw() {
    if (!this.withdrawAmount || isNaN(+this.withdrawAmount)) return
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const web3 = new Web3(window.ethereum)
    const contract = new web3.eth.Contract(BankABI, this.bankContractAddress)
    const gasPrice = await web3.eth.getGasPrice()
    await contract.methods
      .withdraw(web3.utils.toWei(this.withdrawAmount))
      .send({
        from: accounts[0],
        gasPrice,
        gas: '300000',
      })
    this.withdrawAmount = ''
    await this.loadBalance()
  }

  async transfer() {
    if (!this.transferAmount || isNaN(+this.transferAmount)) return
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const web3 = new Web3(window.ethereum)
    const contract = new web3.eth.Contract(BankABI, this.bankContractAddress)
    const gasPrice = await web3.eth.getGasPrice()
    await contract.methods
      .transfer(web3.utils.toWei(this.transferAmount), this.transferAddr)
      .send({
        from: accounts[0],
        gasPrice,
        gas: '300000'
      })
    this.transferAmount = ''
    await this.loadBalance()
  }

  async bankDeposit() {
    if (!this.bankDepositAmount || isNaN(+this.bankDepositAmount)) return
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const web3 = new Web3(window.ethereum)
    const gasPrice = await web3.eth.getGasPrice()
    await web3.eth.sendTransaction({
      from: accounts[0],
      to: this.bankContractAddress,
      value: web3.utils.toWei(this.bankDepositAmount),
      gasPrice,
      gas: '300000'
    })
    this.bankDepositAmount = ''
    await this.loadBalance()
  }

  async arbitrumDeposit() {
    if (!this.arbitrumDepositAmount || isNaN(+this.arbitrumDepositAmount)) return
    const globalInboxAddress = '0x4CAF699D7a468ea81869d768896DA4D3562855Ec'
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const web3 = new Web3(window.ethereum)
    const contract = new web3.eth.Contract(GlobalInboxABI, globalInboxAddress)
    const gasPrice = await web3.eth.getGasPrice()
    await contract.methods.depositEthMessage(this.rollupAddress, accounts[0]).send({
      from: accounts[0],
      gasPrice,
      gas: '200000',
      value: web3.utils.toWei(this.arbitrumDepositAmount),
    })
    this.arbitrumDepositAmount = ''
  }
}
</script>

<style scoped>
.no-metamask {
  margin: 8px;
  font-size: 18px;
  font-weight: bold;
}
.account-info {
  margin: 8px;
  display: flex;
  flex-direction: column;
}
.action-box {
  margin: 8px;
  padding: 4px;
  border: 1px dashed #000;
}
.wrong-network {
  margin: 2px;
  color: red;
}
</style>
