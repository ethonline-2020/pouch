import Web3 from "web3";
import Biconomy from "@biconomy/mexa";

const getWeb3 = web3Torus =>
  new Promise((resolve, reject) => {
    // Wait for loading completion to avoid race conditions with web3 injection timing.
    window.addEventListener("load", async () => {
      // Modern dapp browsers...
      if (window.ethereum) {
        const biconomy = new Biconomy(window.ethereum, {
          dappId: "5e3db06f3a87df0ac4454512",
          apiKey: "gKaGR4WUI.38121703-4858-4819-88e7-d2b20119dfbf"
        });
        // const biconomy = new Biconomy(web3Torus, {
        //   dappId: "5e3db06f3a87df0ac4454512",
        //   apiKey: "gKaGR4WUI.38121703-4858-4819-88e7-d2b20119dfbf"
        // });
        const web3 = new Web3(biconomy);
        // const web3 = new Web3(window.ethereum);
        try {
          // Request account access if needed
          await window.ethereum.enable();
          // Acccounts now exposed
          resolve(web3);
        } catch (error) {
          reject(error);
        }
      }
      // Legacy dapp browsers...
      else if (window.web3) {
        // Use Mist/MetaMask's provider.
        const web3 = window.web3;
        console.log("Injected web3 detected.");
        resolve(web3);
      }
      // Fallback to localhost; use dev console port by default...
      else {
        const provider = new Web3.providers.HttpProvider(
          "http://127.0.0.1:8545"
        );
        const web3 = new Web3(provider);
        console.log("No web3 instance injected, using Local web3.");
        resolve(web3);
      }
    });
  });

export default getWeb3;
