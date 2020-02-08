import TokenInterface from "./contracts/TokenInterface.json";
import Web3 from "web3";
const CONTRACT_ADDRESS = "0x60657a655d17B41F81A11D78c0cae64749df4F40";

const domainSchema = [
  { name: "name", type: "string" },
  { name: "version", type: "string" },
  { name: "chainId", type: "uint256" },
  { name: "verifyingContract", type: "address" }
];

const permitSchema = [
  { name: "holder", type: "address" },
  { name: "spender", type: "address" },
  { name: "nonce", type: "uint256" },
  { name: "expiry", type: "uint256" },
  { name: "allowed", type: "bool" }
];

export default async (web3, signer) => {
  // const web3 = new Web3(window.web3.currentProvider);
  const domainData = {
    name: "Dai Stablecoin",
    version: "1",
    chainId: "42",
    verifyingContract: "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"
  };

  const message = {
    from: {
      name: "You",
      wallet: signer
    },
    to: {
      name: "Pouch",
      wallet: CONTRACT_ADDRESS
    },
    contents: "Pls permit your DAI"
  };

  let typedData = JSON.stringify({
    types: {
      EIP712Domain: domainSchema,
      Permit: permitSchema
    },
    primaryType: "Permit",
    domain: domainData,
    message
  });

  const daiInstance = new web3.eth.Contract(
    TokenInterface.abi,
    "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"
  );

  let nonce = await daiInstance.methods.nonces(signer).call();
  web3.currentProvider.sendAsync(
    {
      method: "eth_signTypedData_v3",
      params: [signer, typedData],
      from: signer
    },
    async function(err, result) {
      if (err) return console.error(err);
      console.log("PERSONAL SIGNED:" + JSON.stringify(result.result));
      const signature = result.result.substring(2);
      const r = "0x" + signature.substring(0, 64);
      const s = "0x" + signature.substring(64, 128);
      const v = parseInt(signature.substring(128, 130), 16);
      // The signature is now comprised of r, s, and v.
      console.log("signature: ", signature);
      await daiInstance.methods
        .permit(signer, CONTRACT_ADDRESS, nonce, 0, true, v, r, s)
        .send({ from: signer, gas: 4000000 });
      // return { r, s, v };
    }
  );
};

// const msgParams = [
//   {
//     type: "string",
//     name: "Message",
//     value:
//       "Hi there! Please permit your DAI to add money to Pouch and transact for free!"
//   },
//   {
//     type: "uint32",
//     name: "DAI Amount",
//     value: "1"
//   }
// ];

// const daiInstance = new web3.eth.Contract(
//   TokenInterface.abi,
//   "0xB5E5D0F8C0cbA267CD3D7035d6AdC8eBA7Df7Cdd"
// );

// web3.currentProvider.sendAsync(
//   {
//     method: "eth_signTypedData",
//     params: [msgParams, signer],
//     from: signer
//   },
//   async function(err, result) {
//     if (err) {
//       return console.error(err);
//     }
//     console.log("PERSONAL SIGNED:" + JSON.stringify(result.result));
//     const signature = result.result.substring(2);
//     const r = "0x" + signature.substring(0, 64);
//     const s = "0x" + signature.substring(64, 128);
//     const v = parseInt(signature.substring(128, 130), 16);
//     // The signature is now comprised of r, s, and v.
//     console.log("signature: ", signature);

//     const nonce = await daiInstance.methods.nonces(CONTRACT_ADDRESS);
//     await daiInstance.methods.permit(
//       signer,
//       CONTRACT_ADDRESS,
//       nonce,
//       0,
//       true,
//       v,
//       r,
//       s
//     );
//   }
// );
