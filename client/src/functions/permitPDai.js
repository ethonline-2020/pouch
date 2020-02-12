import PTokenInterface from "../contracts/PTokenInterface.json"; // TODO: change this
import { PDAI_ADDRESS } from "../constants";

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
  { name: "isAllowed", type: "bool" }
];

export default async (web3, signer, CONTRACT_ADDRESS) => {
  // const web3 = new Web3(window.web3.currentProvider);
  const domainData = {
    name: "Pouch Token",
    version: "1",
    chainId: "42",
    verifyingContract: PDAI_ADDRESS
  };

  const pDaiInstance = new web3.eth.Contract(PTokenInterface.abi, PDAI_ADDRESS);

  let nonce = await pDaiInstance.methods.nonces(signer).call();
  console.log("nonce", nonce);
  const message = {
    holder: signer,
    spender: CONTRACT_ADDRESS,
    nonce: nonce,
    expiry: 0,
    isAllowed: true
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
      await pDaiInstance.methods
        .permitted(signer, CONTRACT_ADDRESS, nonce, 0, true, v, r, s)
        .send({ from: signer, gas: 4000000 });
    }
  );
};
