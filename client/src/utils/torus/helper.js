import Web3 from "web3";
import Torus from "@toruslabs/torus-embed";
import Biconomy from "@biconomy/mexa";

const web3Obj = {
  web3: new Web3(),
  torus: {},
  setweb3: function(provider) {
    // const web3Inst = new Web3(provider);
    // console.log(web3Inst);
    const biconomy = new Biconomy(provider, {
      dappId: "5e3db06f3a87df0ac4454512",
      apiKey: "gKaGR4WUI.38121703-4858-4819-88e7-d2b20119dfbf"
    });
    const web3Inst = new Web3(biconomy);
    // const web3Inst = new Web3(window.ethereum);
    web3Obj.web3 = web3Inst;
  },
  initialize: async function(buildEnv) {
    const torus = new Torus();
    await torus.init({
      buildEnv: buildEnv || "production",
      network: { host: "kovan" }
    });
    await torus.login();
    web3Obj.setweb3(torus.provider);
    web3Obj.torus = torus;
    sessionStorage.setItem("pageUsingTorus", buildEnv);
  }
};
export default web3Obj;
