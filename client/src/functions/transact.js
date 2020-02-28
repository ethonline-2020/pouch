import Pouch from "../contracts/PouchDelegate.json";
// import { PDAI_ADDRESS } from "../constants";
const domainSchema = [
  { name: "name", type: "string" },
  { name: "version", type: "string" },
  { name: "chainId", type: "uint256" },
  { name: "verifyingContract", type: "address" }
];

const transactSchema = [
  { name: "holder", type: "address" },
  { name: "to", type: "address" },
  { name: "value", type: "uint256" },
  { name: "nonce", type: "uint256" }
];

export default async (web3, signer, CONTRACT_ADDRESS, value, recipient, cb) => {
  // const web3 = new Web3(window.web3.currentProvider);
  console.log(CONTRACT_ADDRESS);
  const domainData = {
    name: "Pouch Token",
    version: "1",
    chainId: 42,
    verifyingContract: CONTRACT_ADDRESS
  };

  // const deployedNetwork = Pouch.networks["42"];
  const pouchInstance = new web3.eth.Contract(Pouch.abi, CONTRACT_ADDRESS);
  let nonce = await pouchInstance.methods.nonces(signer).call();
  const message = {
    holder: signer,
    to: recipient,
    value: value,
    nonce: nonce
  };

  let typedData = JSON.stringify({
    types: {
      EIP712Domain: domainSchema,
      Transact: transactSchema
    },
    primaryType: "Transact",
    domain: domainData,
    message
  });
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
      await pouchInstance.methods
        .transactTest(signer, recipient, value, nonce, r, s, v)
        .send({ from: signer, gas: 4000000 })
        .on("transactionHash", hash => cb(hash));
    }
  );
};
