import React, { Component } from "react";
import PouchContract from "./contracts/Pouch.json";
import TokenInterface from "./contracts/TokenInterface.json";
import PTokenInterface from "./contracts/EIP20Interface.json";
import getWeb3 from "./web3/getWeb3";
import "./App.css";
import permitDai from "./functions/permitDai";
import permitPDai from "./functions/permitPDai";
import depositDai from "./functions/deposit";
import withdrawDai from "./functions/withdraw";
import { PDAI_ADDRESS } from "./constants";
class App extends Component {
  state = {
    allowance: 0,
    pDaiAllowance: 0,
    web3: null,
    accounts: null,
    contract: null,
    daiContract: null,
    contractAddress: null,
    pDaiContract: null
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = PouchContract.networks[networkId];
      const instance = new web3.eth.Contract(
        PouchContract.abi,
        deployedNetwork && deployedNetwork.address
      );

      const daiContract = new web3.eth.Contract(
        TokenInterface.abi,
        "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"
      );

      const pDaiContract = new web3.eth.Contract(
        PTokenInterface.abi,
        PDAI_ADDRESS
      );

      // await approveDAI(100, { from: accounts[0], gas: "3000000" });

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState(
        {
          web3,
          accounts,
          contract: instance,
          daiContract,
          contractAddress: deployedNetwork && deployedNetwork.address,
          pDaiContract
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

  handleDeposit = async () => {
    const {
      web3,
      accounts,
      contract,
      daiContract,
      contractAddress
    } = this.state;

    // await contract.methods
    //   .deposit(accounts[0], "1000000000000000000")
    //   .send({ from: accounts[0], gas: 4000000 });
    await depositDai(web3, accounts[0], contractAddress, "1000000000000000000");
  };

  handleWithdraw = async () => {
    const { web3, accounts, contractAddress } = this.state;

    await withdrawDai(
      web3,
      accounts[0],
      contractAddress,
      "1000000000000000000"
    );
  };

  getAllowance = async () => {
    const {
      web3,
      accounts,
      daiContract,
      contractAddress,
      pDaiContract
    } = this.state;
    const allowance = await daiContract.methods
      .allowance(accounts[0], contractAddress)
      .call();

    const pDaiAllowance = await pDaiContract.methods
      .allowance(accounts[0], contractAddress)
      .call();

    console.log(pDaiAllowance);

    this.setState({ allowance, pDaiAllowance });
  };

  signDai = async () => {
    const { web3, accounts, daiContract, contractAddress } = this.state;
    await permitDai(web3, accounts[0], contractAddress);
  };

  signPDai = async () => {
    const { web3, accounts, daiContract, contractAddress } = this.state;
    await permitPDai(web3, accounts[0], contractAddress);
  };
  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Pouch</h1>
        <button onClick={this.handleDeposit}>Deposit 1.0 DAI</button>
        <button onClick={this.handleWithdraw}>Withdraw 1.0 DAI</button>
        <button onClick={this.signDai}>Sign & Permit DAI</button>
        <button onClick={this.signPDai}>Sign & Permit pDAI</button>
        <div>Allowance: {this.state.allowance}</div>
        <div>pDAI Allowance: {this.state.pDaiAllowance}</div>
      </div>
    );
  }
}

export default App;
