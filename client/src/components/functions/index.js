import React, { Component } from "react";
import depositDai from "../../functions/deposit";
import withdrawDai from "../../functions/withdraw";
import transactDai from "../../functions/transact";

export default class Functions extends Component {
  constructor() {
    super();
    this.state = {
      addAmount: null,
      withdrawAmount: null,
      sendAmount: null,
      sendAddress: null,
      web3: null,
      accounts: null,
      contract: null,
      daiContract: null,
      contractAddress: null
      // pDaiContract: null
    };
  }

  handleDeposit = async () => {
    const { addAmount } = this.state;
    const { accounts, web3, contractAddress } = this.props;
    if (!addAmount) return;

    await depositDai(
      web3,
      accounts[0],
      contractAddress,
      web3.utils.toWei(addAmount, "ether")
    );

    this.setState({ addAmount: "" });
  };

  handleWithdraw = async () => {
    const { withdrawAmount } = this.state;
    const { accounts, web3, contractAddress } = this.props;
    if (!withdrawAmount) return;
    await withdrawDai(
      web3,
      accounts[0],
      contractAddress,
      web3.utils.toWei(withdrawAmount, "ether")
    );
    this.setState({ withdrawAmount: "" });
  };

  handleTransact = async () => {
    const { sendAddress, sendAmount } = this.state;
    const { accounts, web3, contractAddress } = this.props;
    await transactDai(
      web3,
      accounts[0],
      contractAddress,
      web3.utils.toWei(sendAmount, "ether"),
      sendAddress
    );
  };

  handleChange = event => {
    this.setState({ [event.target.name]: event.target.value });
  };

  render() {
    const { addAmount, withdrawAmount, sendAmount, sendAddress } = this.state;

    const { accounts } = this.props;
    return (
      <div className="container">
        <div className="row justify-content-center pt-5">
          <div className="col-8">
            <div className="card text-white bg-danger m-auto p-3 shadow">
              <h6 className="text-center">Wallet Balance</h6>
              <h1 className="text-center bold">$100</h1>
              <p className="text-center">{accounts && accounts[0]}</p>
            </div>
          </div>
        </div>
        <div className="row justify-content-center pt-5">
          <div className="col-4">
            <div className="card bg-light m-auto p-3 shadow border-light">
              <h6 className="text-center">Add money</h6>
              <input
                className="form-control form-control-lg my-3"
                type="number"
                name="addAmount"
                placeholder="Enter amount in DAI"
                onChange={this.handleChange}
              />
              <button
                type="button"
                className="btn btn-success text-center btn-lg"
                onClick={this.handleDeposit}
              >
                Add {addAmount ? `${addAmount} DAI` : ""} &#x1F4B0;&#x1F525;
              </button>
            </div>
          </div>
          <div className="col-4">
            <div className="card bg-light m-auto p-3 shadow border-light">
              <h6 className="text-center">Withdraw money</h6>
              <input
                className="form-control form-control-lg my-3"
                type="number"
                name="withdrawAmount"
                placeholder="Enter amount in DAI"
                onChange={this.handleChange}
              />
              <button
                type="button"
                className="btn btn-danger text-center btn-lg"
                onClick={this.handleWithdraw}
              >
                Withdraw {withdrawAmount ? `${withdrawAmount} DAI ` : " "}
                &#x1F911;&#x26A1;
              </button>
            </div>
          </div>
        </div>
        <div className="row justify-content-center pt-5">
          <div className="col-8">
            <div className="card bg-light m-auto p-3 shadow border-light">
              <h6 className="text-center">Send Money</h6>
              <input
                className="form-control form-control-lg my-1"
                type="text"
                name="sendAddress"
                placeholder="Enter address"
                onChange={this.handleChange}
              />
              <input
                className="form-control form-control-lg mb-3"
                type="number"
                name="sendAmount"
                placeholder="Enter amount in DAI"
                onChange={this.handleChange}
              />
              <button
                type="button"
                className="btn btn-dark text-center btn-lg"
                onClick={this.handleTransact}
              >
                Send &#x1F4B8;&#x1F4AF;
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
