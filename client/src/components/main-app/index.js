import React, { Component } from "react";
import web3Obj from "../../utils/torus/helper";
import Info from "../../components/info";
import LeftMenu from "../../components/left-menu";
import Functions from "../../components/functions";
import PouchContract from "../../contracts/PouchDelegate.json";
import TokenInterface from "../../contracts/TokenInterface.json";
import permitDai from "../../functions/permitDai";
import TorusLogin from "../torus-login";
import RewardPopup from "../reward-popup";
import CreateWallet from "../create-wallet";
export default class MainApp extends Component {
  state = {
    account: null,
    balance: "",
    selectedVerifier: "google",
    placeholder: "Enter google email",
    verifierId: null,
    buildEnv: "testing",
    accounts: null,
    userInfo: null,
    show: false,
    totalRewards: 0
  };

  async componentDidMount() {
    const isTorus = sessionStorage.getItem("pageUsingTorus");
    if (isTorus) {
      web3Obj.initialize(isTorus).then(() => {
        this.setStateInfo();
      });
    }

    // const web3 = await getWeb3();
    // const web3 = await web3Obj.web3;
  }

  setStateInfo = async () => {
    // web3Obj.web3.eth.getAccounts().then(accounts => {
    //   this.setState({ accounts: accounts });
    // });
    const accounts = await web3Obj.web3.eth.getAccounts();
    // Get the contract instance.
    // const networkId = await web3Obj.web3.eth.net.getId();
    const deployedNetwork = PouchContract.networks[42];
    const instance = new web3Obj.web3.eth.Contract(
      PouchContract.abi,
      deployedNetwork && deployedNetwork.address
    );

    const daiContract = new web3Obj.web3.eth.Contract(
      TokenInterface.abi,
      "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"
    );

    // Set web3, accounts, and contract to the state, and then proceed with an
    // example of interacting with the contract's methods.
    this.setState(
      {
        accounts,
        web3: web3Obj.web3,
        contract: instance,
        daiContract,
        contractAddress: deployedNetwork && deployedNetwork.address
      },
      () => {
        this.getAllowance();
        this.getBalance();
        this.getDaiBalance();
        this.getUserInfo();
        this.checkProfits();
        this.getUserRewards();
      }
    );
    // web3Obj.web3.eth.getBalance(accounts[0]).then(balance => {
    //   this.setState({ balance: balance });
    // });
  };

  enableTorus = async e => {
    const { buildEnv } = this.state;
    e.preventDefault();
    try {
      await web3Obj.initialize(buildEnv);
      this.setStateInfo();
    } catch (error) {
      console.error(error);
    }
  };

  getUserInfo = async () => {
    const userInfo = await web3Obj.torus.getUserInfo();
    // this.console(userInfo);
    this.setState({ userInfo });
  };

  getPublicAddress = async recipientEmail => {
    const recipientAddress = await web3Obj.torus.getPublicAddress({
      verifier: this.state.selectedVerifier,
      verifierId: recipientEmail
    });
    return recipientAddress;
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

  getUserRewards = async () => {
    const { web3, accounts, contract } = this.state;

    const totalRewards = await contract.methods.rewards(accounts[0]).call();
    this.setState({ totalRewards: web3.utils.fromWei(totalRewards, "ether") });
  };

  signDaiForDelegate = async () => {
    const { web3, accounts, contractAddress } = this.state;
    await permitDai(web3, accounts[0], contractAddress);
  };

  checkProfits = async () => {
    const { contract } = this.state;
    const profits = await contract.methods
      .checkProfits()
      .call({ from: "0x5222318905891Ae154c3FA5437830cAA86be5499" });
    console.log("*******Profits********", profits);
  };

  spitProfits = async () => {
    const { contract, accounts } = this.state;
    await contract.methods.spitProfits().send({
      from: accounts[0],
      gas: 3000000
    });
  };

  showModal = () => {
    this.setState({ show: true });
  };

  closeModal = () => {
    this.setState({ show: false });
  };

  render() {
    let {
      accounts,
      balance,
      userInfo,
      daiBalance,
      contractAddress,
      allowanceForDelegate,
      contract,
      totalRewards,
      show
    } = this.state;
    console.log("totalRewards", totalRewards);
    return (
      <div className="App">
        <RewardPopup show={show} close={this.closeModal} />
        {!accounts && <TorusLogin enableTorus={this.enableTorus} />}
        {accounts &&
          accounts[0] &&
          (allowanceForDelegate > 0 ? (
            <div className="container-fluid">
              <div className="row">
                <div className="col-3">
                  <LeftMenu userInfo={userInfo} totalRewards={totalRewards} />
                </div>
                <div className="col-9">
                  <Info
                    balance={balance}
                    accounts={accounts}
                    web3={web3Obj.web3}
                    contractAddress={contractAddress}
                    daiBalance={daiBalance}
                  />
                  <Functions
                    accounts={accounts}
                    web3={web3Obj.web3}
                    contractAddress={contractAddress}
                    getPublicAddress={this.getPublicAddress}
                    showModal={this.showModal}
                    contract={contract}
                  />
                </div>
              </div>
            </div>
          ) : (
            <CreateWallet signDaiForDelegate={this.signDaiForDelegate} />
          ))}
        {/* <button onClick={this.spitProfits}>Spit profits</button> */}
      </div>
    );
  }
}
