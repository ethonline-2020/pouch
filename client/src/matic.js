// Import Matic sdk
import Matic from "@maticnetwork/maticjs";

// Create sdk instance
const matic = new Matic({
  // Set Matic provider - string or provider instance
  // Example: 'https://testnet.matic.network' OR new Web3.providers.HttpProvider('http://localhost:8545')
  // Some flows like startExitFor[Metadata]MintableBurntToken, require a webSocket provider such as new web3.providers.WebsocketProvider('ws://localhost:8546')
  maticProvider: "https://testnetv2.matic.network",

  // Set Mainchain provider - string or provider instance
  // Example: 'https://kovan.infura.io' OR new Web3.providers.HttpProvider('http://localhost:8545')
  parentProvider: "https://ropsten.infura.io",

  // Set rootchain contract. See below for more information
  rootChain: "0x82a72315E16cE224f28E1F1fB97856d3bF83f010",

  // Set registry contract. See below for more information
  registry: "0x56B082d0a590A7ce5d170402D6f7f88B58F71988",

  // Set withdraw-manager Address. See below for more information
  withdrawManager: "0x3cf9aD3395028a42EAfc949e2EC4588396b8A7D4",

  // Set deposit-manager Address. See below for more information
  depositManager: "0x3Bc6701cA1C32BBaC8D1ffA2294EE3444Ad93989"
});

// init matic

matic.initialize();

// Set wallet
// Warning: Not-safe
// matic.setWallet(<private-key>) // Use metamask provider or use WalletConnect provider instead.

// get ERC20 token balance
// export const balanceOfERC20 = async (user, tokenAddress, options = {}) =>
//   await matic.balanceOfERC20(
//     user, //User address
//     tokenAddress, // Token address
//     options // transaction fields
//   );

// // get ERC721 token balance
// await matic.balanceOfERC721(
//   user, // User address
//   tokenAddress, // Token address
//   options // transaction fields
// );

// // get ERC721 token ID
// await matic.tokenOfOwnerByIndexERC721(
//   from, // User address
//   tokenAddress, // Token address
//   index, // index of tokenId
//   options // transaction fields
// );

// // Deposit Ether into Matic chain
// await matic.depositEthers(
//   amount, // amount in wei for deposit
//   options // transaction fields
// );

// Approve ERC20 token for deposit
export const approveDAI = async (amount, options = {}) =>
  await matic.approveERC20TokensForDeposit(
    "0xB5E5D0F8C0cbA267CD3D7035d6AdC8eBA7Df7Cdd", // Token address,
    amount, // Token amount for approval (in wei)
    options // transaction fields
  );

// // Deposit token into Matic chain. Remember to call `approveERC20TokensForDeposit` before
// await matic.depositERC20ForUser(
//   token, // Token address
//   user, // User address (in most cases, this will be sender's address),
//   amount, // Token amount for deposit (in wei)
//   options // transaction fields
// );

// // Deposit ERC721 token into Matic chain.
// await matic.safeDepositERC721Tokens(
//   token, // Token address
//   tokenId, // TokenId for deposit
//   options // transaction fields
// );

// // Transfer token on Matic
// await matic.transferERC20Tokens(
//   token, // Token address
//   user, // Recipient address
//   amount, // Token amount
//   options // transaction fields
// );

// // Transfer ERC721 token on Matic
// await matic.transferERC721Tokens(
//   token, // Token address
//   user, // Recipient address
//   tokenId, // TokenId
//   options // transaction fields
// );

// // Initiate withdrawal of ERC20 from Matic and retrieve the Transaction id
// await matic.startWithdraw(
//   token, // Token address
//   amount, // Token amount for withdraw (in wei)
//   options // transaction fields
// );

// // Initiate withdrawal of ERC721 from Matic and retrieve the Transaction id
// await matic.startWithdrawForNFT(
//   token, // Token address
//   tokenId, // TokenId for withdraw
//   options // transaction fields
// );

// // Withdraw funds from the Matic chain using the Transaction id generated from the 'startWithdraw' method
// // after header has been submitted to mainchain
// await matic.withdraw(
//   txId, // Transaction id generated from the 'startWithdraw' method
//   options // transaction fields
// );

// await matic.withdrawNFT(
//   txId, // Transaction id generated from the 'startWithdraw' method
//   options // transaction fields
// );

// await matic.processExits(
//   tokenAddress, // root `token` addres
//   options // transaction fields
// );
