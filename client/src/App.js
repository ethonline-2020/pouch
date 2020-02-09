import React, { Component } from "react";
import BoundlessContract from "./contracts/Boundless.json";
import TokenInterface from "./contracts/TokenInterface.json";
import getWeb3 from "./getWeb3";
// import { approveDAI } from "./matic";
import "./App.css";
import permitDai from "./permit";

class App extends Component {
  state = {
    allowance: 0,
    web3: null,
    accounts: null,
    contract: null,
    daiContract: null,
    contractAddress: null
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
        "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"
      );

      // await approveDAI(100, { from: accounts[0], gas: "3000000" });

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState(
        {
          web3,
          accounts,
          contract: instance,
          daiContract: daiInstance,
          contractAddress: deployedNetwork && deployedNetwork.address
        },
        // this.runExample

        this.getAllowance
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

  // runExample = async () => {
  //   const { web3, contract, accounts } = this.state;

  //   const allowance = await contract.methods
  //     .checkDaiAllowance()
  //     .call({ from: accounts[0] });
  //   console.log(allowance);
  //   // await contract.methods.deposit(1).send({ from: accounts[0] });

  //   // Get the value from the contract to prove it worked.
  //   // const response = await contract.methods.get().call();

  //   // Update state with the result.
  //   this.setState({ allowance });
  // };

  handleApprove = async () => {
    const { web3, accounts, daiContract } = this.state;
    const BN = web3.utils.BN;
    // const amount = this.bigNumInString("1000000");
    await daiContract.methods
      .approve(accounts[0], "1000000000000000000")
      .send({ from: accounts[0] });
  };

  handleDeposit = async () => {
    const {
      web3,
      accounts,
      contract,
      daiContract,
      contractAddress
    } = this.state;
    // const BN = web3.utils.BN;
    // const amount = this.bigNumInString("1000000");
    await daiContract.methods
      .transferFrom(accounts[0], contractAddress, 100)
      .send({ from: accounts[0], gas: 2000000 });
    // await contract.methods
    //   .deposit(accounts[0], "100000")
    //   .send({ from: accounts[0], gas: 4000000 });
  };

  getAllowance = async () => {
    const { web3, accounts, daiContract, contractAddress } = this.state;
    // const amount = this.bigNumInString("1000000");
    const allowance = await daiContract.methods
      .allowance(accounts[0], contractAddress)
      .call();

    console.log(allowance);

    this.setState({ allowance });
  };

  sign = async () => {
    const { web3, accounts, daiContract, contractAddress } = this.state;
    await permitDai(web3, accounts[0], contractAddress);
  };
  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Pouch</h1>
        <button onClick={this.handleApprove}>Approve 1 DAI</button>
        {/* <button onClick={this.signTx}>Deposit</button> */}
        <button onClick={this.handleDeposit}>Deposit 0.1 DAI</button>
        <button onClick={this.sign}>Sign with metamask</button>
        <div>Allowance: {this.state.allowance}</div>
      </div>
    );
  }
}

export default App;
