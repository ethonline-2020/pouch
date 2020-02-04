import React, { Component } from "react";
import BoundlessContract from "./contracts/Boundless.json";
import TokenInterface from "./contracts/TokenInterface.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = {
    allowance: 0,
    web3: null,
    accounts: null,
    contract: null,
    daiContract: null
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = BoundlessContract.networks[networkId];
      const instance = new web3.eth.Contract(
        BoundlessContract.abi,
        deployedNetwork && deployedNetwork.address
      );

      const daiInstance = new web3.eth.Contract(
        TokenInterface.abi,
        "0xB5E5D0F8C0cbA267CD3D7035d6AdC8eBA7Df7Cdd"
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState(
        { web3, accounts, contract: instance, daiContract: daiInstance },
        this.runExample
      );
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.error(error);
    }
  };

  bigNumInString(x) {
    if (Math.abs(x) < 1.0) {
      var e = parseInt(x.toString().split("e-")[1]);
      if (e) {
        x *= Math.pow(10, e - 1);
        x = "0." + new Array(e).join("0") + x.toString().substring(2);
      }
    } else {
      var e = parseInt(x.toString().split("+")[1]);
      if (e > 20) {
        e -= 20;
        x /= Math.pow(10, e);
        x += new Array(e + 1).join("0");
      }
    }
    return x;
  }

  signTx = async () => {
    const { web3, accounts, contract } = this.state;
    let address = "0x5222318905891Ae154c3FA5437830cAA86be5499";
    let contractAddress = "0x1d2175eBC6bd4490De8F8bF07Fd8fcD371357FDc";
    let privateKey = "123";
    let txParams = {
      from: address,
      gas: web3.utils.toHex(210000),
      gasPrice: "20000000000",
      to: contractAddress,
      value: "0x0",
      data: contract.methods.deposit(1).encodeABI()
    };

    const signedTx = await web3.eth.accounts.signTransaction(
      txParams,
      accounts[0]
    );

    console.log(signedTx);

    let receipt = await web3.eth.sendSignedTransaction(
      signedTx.raw,
      (error, txHash) => {
        if (error) {
          return console.error(error);
        }
        console.log(txHash);
      }
    );
  };

  runExample = async () => {
    const { web3, contract } = this.state;

    const allowance = await contract.methods.checkDaiAllowance().call();
    console.log(allowance);
    // await contract.methods.deposit(1).send({ from: accounts[0] });

    // Get the value from the contract to prove it worked.
    // const response = await contract.methods.get().call();

    // Update state with the result.
    this.setState({ allowance });
  };

  handleApprove = async () => {
    const { web3, accounts, daiContract } = this.state;
    const BN = web3.utils.BN;
    // const amount = this.bigNumInString("1000000");
    await daiContract.methods
      .approve(
        "0x1d2175eBC6bd4490De8F8bF07Fd8fcD371357FDc",
        new BN("1000000000000000000").toString()
      )
      .send({ from: accounts[0] });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Boundless</h1>
        <button onClick={this.handleApprove}>Approve 1 DAI</button>
        <button onClick={this.signTx}>Deposit</button>
        <div>Allowance: {this.state.allowance}</div>
      </div>
    );
  }
}

export default App;
