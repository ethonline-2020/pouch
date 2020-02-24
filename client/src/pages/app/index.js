import React from "react";
import Info from "../../components/info";
import LeftMenu from "../../components/left-menu";
import Functions from "../../components/functions";
import PouchContract from "../../contracts/PouchDelegate.json";
import Pouch from "../../contracts/Pouch.json";
import TokenInterface from "../../contracts/TokenInterface.json";
import getWeb3 from "../../utils/web3/getWeb3";
import web3Obj from "../../utils/torus/helper";

export default class PouchApp extends React.Component {
  state = {
    allowanceForPouch: 0,
    allowanceForDelegate: 0,
    pDaiAllowance: 0,
    web3: null,
    accounts: null,
    contract: null,
    daiContract: null,
    contractAddress: null,
    balance: 0,
    daiBalance: 0,
    web3Torus: null
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // get torus
      const isTorus = sessionStorage.getItem("pageUsingTorus");
      if (isTorus) {
        web3Obj.initialize(isTorus).then(() => {
          this.setStateInfo();
          this.getUserInfo();
        });
      }
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
          contractAddress: deployedNetwork && deployedNetwork.address,
          web3Torus: web3Obj
          // pDaiContract
        },
        () => {
          this.getAllowance();
          this.getBalance();
          this.getDaiBalance();
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

  getDaiBalance = async () => {
    const { web3, accounts, daiContract } = this.state;
    const daiBalance = await daiContract.methods.balanceOf(accounts[0]).call();
    this.setState({ daiBalance: web3.utils.fromWei(daiBalance, "ether") });
  };

  setStateInfo = () => {
    web3Obj.web3.eth.getAccounts().then(accounts => {
      this.setState({ account: accounts[0] });
      web3Obj.web3.eth.getBalance(accounts[0]).then(balance => {
        this.setState({ balance: balance });
      });
    });
  };

  getUserInfo = async () => {
    const userInfo = await web3Obj.torus.getUserInfo();
    console.log(userInfo);
  };

  render() {
    const {
      accounts,
      web3,
      web3Torus,
      contractAddress,
      balance,
      daiBalance
    } = this.state;
    if (!web3) {
      return (
        <div className="text-center text-white ">
          Loading Web3, accounts, and contract...
        </div>
      );
    }
    return (
      <div className="container-fluid">
        <div className="row">
          <div className="col-3">
            <LeftMenu />
          </div>
          <div className="col-9">
            <Info
              balance={balance}
              accounts={accounts}
              web3={web3}
              contractAddress={contractAddress}
              daiBalance={daiBalance}
            />
            <Functions
              accounts={accounts}
              web3={web3}
              contractAddress={contractAddress}
            />
          </div>
        </div>
      </div>
    );
  }
}
