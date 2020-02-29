# Pouch Wallet

Pouch is a peer-to-peer payments and utility dApp, with an inbuilt reward system, on top of Compound Finance.

## Setup

```
git clone https://github.com/ethonline-2020/pouch/tree/ui-revamp
cd pouch && npm install
cd client && npm install
npm run start
```

Navigate to localhost:3000 to view the React app.

## Compile and Deploy

Create .env with these fields

```
MNEMONIC=<12 word mnemonic phrase>
INFURA_ID=<infura app id>
```

```
truffle compile
truffle deploy --reset --network ropsten
```

## What is Pouch Wallet

Pouch solves the problem of onboarding new users to the crypto ecosytem as well as overhauling the user experience of existing users by incentivising users to interact with our platform, all with a long term and sustainable business model.

**The experience of Web2 on Web3.**

**What Pouch Solves?**

**Free Gasless Transactions**
Pouch lets users sign the transactions and the relayers sends that transaction to the blockchain with no charges for the user.

**Seamless UX**
The UX was designed to attract the new crypto users in mind. At no point does the user feels out of place.

**Abstracted UI**
Exctract only relevant information and ignore inessential details.

**Incentive Driven Approach**
Rewarding users for interacting with our dApp.

**Metamask-LESS**
No additional hurdles for users to start interacting with blockchain.

** How Pouch Solves?**

** Generating Interest through Compound**
Dai deposited in our contracts mints cDai which helps us to give out rewards and incentives to users.

** Native Token**
Existing tokens make for great use cases but hampers the UX without meta transactions.
Pouch Token ( PCH) is built from ground up with meta transactions at every core activity of the user.

_PCH is redeemable 1:1 DAI at any point in time._
