# Boundless

A smart wallet for free P2P transactions in DAI, powered by Compound protocol

## Setup

```
git clone https://github.com/ethonline-2020/boundless.git
cd boundless && npm install
cd client && npm install
npm run start
```

Navigate to localhost:3000 to view the React app.

## Contract address

0x1d2175eBC6bd4490De8F8bF07Fd8fcD371357FDc

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
