/// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface ArbSys {
  // Send given amount of ERC-20 tokens to dest with token contract sender.
  // This is safe to freely call since the sender is authenticated and thus
  // you can only send fake tokens, not steal real ones
  function withdrawERC20(address dest, uint256 amount) external;

  // Send given ERC-721 token to dest with token contract sender.
  // This is safe by the above arguement
  function withdrawERC721(address dest, uint256 id) external;

  // Send given amount of Eth to dest with from sender.
  function withdrawEth(address dest) external payable;

  // Return the number of transactions issued by the given external account
  // or the account sequence number of the given contract
  function getTransactionCount(address account) external view returns(uint256);

  // Return the value of the storage slot for the given account at the given index
  // This function is only callable from address 0 to prevent contracts from being
  // able to call it
  function getStorageAt(address account, uint256 index) external view returns (uint256);
}

/// Bank stores Ether and allows users to transfer value to other users

contract Bank {

  // Can also be written as ArbSys(100) if you're cool
  ArbSys constant system = ArbSys(0x0000000000000000000000000000000000000064);
  mapping (address => uint) balances;

  event Deposit(address from, uint amount);
  event Transfer(address from, address to, uint amount);
  event Withdrawal(address from, address to, uint amount);

  fallback() external payable {
    balances[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
  }

  function transfer(uint amount, address to) public {
    require(amount <= balances[msg.sender], "Bank: Invalid withdrawal amount");
    require(amount > 0, "Bank: Invalid withdrawal amount");
    balances[msg.sender] -= amount;
    balances[to] += amount;
    emit Transfer(msg.sender, to, amount);
  }

  function withdraw(uint _amount) public {
    withdrawTo(_amount, msg.sender);
  }

  function withdrawTo(uint _amount, address receiver) public {
    uint amount = _amount == 0 ? balances[msg.sender] : _amount;
    require(amount <= balances[msg.sender], "Bank: Invalid withdrawal amount");
    require(amount > 0, "Bank: Invalid withdrawal amount");
    balances[msg.sender] -= amount;
    system.withdrawEth{value: amount}(receiver);
    emit Withdrawal(msg.sender, receiver, amount);
  }

  function balance(address owner) public view returns (uint) {
    return balances[owner];
  }
}
