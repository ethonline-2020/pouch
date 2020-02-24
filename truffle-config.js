require("dotenv").config();
const mnemonic = process.env.MNEMONIC;
const HDWalletProvider = require("truffle-hdwallet-provider");
// Create your own key for Production environments (https://infura.io/)
const INFURA_ID = process.env.INFURA_ID || "d6760e62b67f4937ba1ea2691046f06d";

// const configNetwork = (
//   network,
//   networkId,
//   path = "m/44'/60'/0'/0/",
//   gas = 4465030,
//   gasPrice = 1e10
// ) => ({
//   provider: () =>
//     new HDWalletProvider(
//       mnemonic,
//       `https://${network}.infura.io/v3/${INFURA_ID}`,
//       0,
//       1,
//       true,
//       path
//     ),
//   networkId,
//   gas,
//   gasPrice
// });

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${INFURA_ID}`),
      gasPrice: 10000000000,
      network_id: 3
    },
    kovan: {
      provider: () => new HDWalletProvider(mnemonic, `https://kovan.infura.io/v3/${INFURA_ID}`),
      gasPrice: 10000000000,
      network_id: 42
    }
    // kovan: configNetwork("kovan", 42),
    // rinkeby: configNetwork("rinkeby", 4),
    // main: configNetwork("mainnet", 1)
  }
};

// module.exports = {
//   // See <http://truffleframework.com/docs/advanced/configuration>
//   // to customize your Truffle configuration!
//   contracts_build_directory: path.join(__dirname, "client/src/contracts"),
//   networks: {
//     develop: {
//       port: 8545
//     }
//   }
// };
