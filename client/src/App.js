import React, { Component } from "react";
import PouchContract from "./contracts/PouchDelegate.json";
import Pouch from "./contracts/Pouch.json";
import TokenInterface from "./contracts/TokenInterface.json";
import getWeb3 from "./web3/getWeb3";
import "./App.css";
import permitDai from "./functions/permitDai";
import permitPDai from "./functions/permitPDai";
import depositDai from "./functions/deposit";
import withdrawDai from "./functions/withdraw";
import transactDai from "./functions/transact";
import Functions from "./components/functions";
import MainApp from "./pages/app";

class App extends Component {
  state = {
    allowanceForPouch: 0,
    allowanceForDelegate: 0,
    pDaiAllowance: 0,
    web3: null,
    accounts: null,
    contract: null,
    daiContract: null,
    contractAddress: null,
    balance: 0
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

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState(
        {
          web3,
          accounts,
          contract: instance,
          daiContract,
          contractAddress: deployedNetwork && deployedNetwork.address
          // pDaiContract
        },
        () => {
          this.getAllowance();
          this.getBalance();
        }
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
    const { web3, accounts, contractAddress } = this.state;

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

  handleTransact = async () => {
    const { web3, accounts, contractAddress } = this.state;

    await transactDai(web3, accounts[0], contractAddress, "100000000000000000");
  };

  getAllowance = async () => {
    const { accounts, daiContract, contractAddress } = this.state;
    const allowanceForDelegate = await daiContract.methods
      .allowance(accounts[0], contractAddress)
      .call();

    this.setState({
      allowanceForDelegate
    });
  };

  getBalance = async () => {
    const {
      web3,
      accounts,
      contract
      // pDaiContract
    } = this.state;
    const balance = await contract.methods.balanceOf(accounts[0]).call();
    this.setState({ balance: web3.utils.fromWei(balance, "ether") });
  };

  signDaiForDelegate = async () => {
    const { web3, accounts, contractAddress } = this.state;
    await permitDai(web3, accounts[0], contractAddress);
  };

  signDaiForPouch = async () => {
    const deployedNetwork = Pouch.networks["42"];

    const { web3, accounts } = this.state;
    await permitDai(web3, accounts[0], deployedNetwork.address);
  };

  signPDai = async () => {
    const { web3, accounts, contractAddress } = this.state;
    await permitPDai(web3, accounts[0], contractAddress);
  };
  render() {
    const {
      accounts,
      web3,
      contractAddress,
      allowanceForDelegate,
      balance
    } = this.state;
    if (!this.state.web3) {
      return (
        <div className="text-center text-white ">
          Loading Web3, accounts, and contract...
        </div>
      );
    }
    console.log("delegate allowance:", allowanceForDelegate);
    return (
      <MainApp
        balance={balance}
        accounts={accounts}
        web3={web3}
        contractAddress={contractAddress}
      />
    );

    // return (
    //   <div className="bg">
    //     <div className="container pt-4 mt-3">
    //       <div className="custom-card">
    //         <h1 className="text-center bold">Welcome to Pouch</h1>
    //         {allowanceForDelegate > 0 ? (
    //           <Functions
    //             balance={balance}
    //             accounts={accounts}
    //             web3={web3}
    //             contractAddress={contractAddress}
    //           />
    //         ) : (
    //           <div className="container">
    //             <div className="text-center">
    //               Create your smart wallet with a single click!
    //             </div>
    //             <div className="d-flex row justify-content-center pt-5">
    //               <button
    //                 type="button"
    //                 className="btn btn-primary text-center btn-lg mx-3"
    //                 onClick={this.signDaiForDelegate}
    //                 disabled={allowanceForDelegate > 0}
    //               >
    //                 {/* Sign & Permit DAI */}
    //                 Create Wallet
    //               </button>
    //             </div>
    //           </div>
    //         )}
    //         {/* <button onClick={this.signPDai}>Sign & Permit pDAI</button> */}
    //         {/* <button onClick={this.signDaiForPouch}>Sign & Permit DAI</button> */}
    //         {/* <button onClick={this.handleDeposit}>Deposit 1.0 DAI</button>
    //         <button onClick={this.handleWithdraw}>Withdraw 1.0 DAI</button>
    //         <button onClick={this.handleTransact}>Transact 0.1 DAI</button>
    //         <div>Allowance: {this.state.allowance}</div>
    //         <div>pDAI Allowance: {this.state.pDaiAllowance}</div> */}
    //       </div>
    //     </div>
    //   </div>
    // );
  }
}

export default App;
