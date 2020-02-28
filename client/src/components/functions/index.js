import React, { Component } from "react";
import depositDai from "../../functions/deposit";
import withdrawDai from "../../functions/withdraw";
import transactDai from "../../functions/transact";
import "./styles.css";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default class Functions extends Component {
  constructor() {
    super();
    this.state = {
      addAmount: null,
      withdrawAmount: null,
      sendAmount: null,
      recipientEmail: null,
      web3: null,
      accounts: null,
      contract: null,
      daiContract: null,
      txHash: null,
      show: false
      // contractAddress: null
      // pDaiContract: null
    };
  }

  showToasts(txHash) {
    toast("🦄 Tx Pending");
    setTimeout(() => {
      toast("🦄 Tx added to block. Awaiting confirmations");
    }, 3000);
    setTimeout(() => {
      toast.success(
        <a
          href={`https://kovan.etherscan.io/tx/${txHash}`}
          target="_blank"
          rel="noopener noreferrer"
          className="tx-link"
        >
          Tx Confirmed! Click here to view.
        </a>
      );
    }, 8000);
  }

  handleDeposit = async () => {
    const { addAmount } = this.state;
    const { accounts, web3, contractAddress } = this.props;
    if (!addAmount) return;

    await depositDai(
      web3,
      accounts[0],
      contractAddress,
      web3.utils.toWei(addAmount, "ether"),
      txHash => {
        this.setState({ txHash, addAmount: "" });
        this.showToasts(txHash);
      }
    );
  };

  handleWithdraw = async () => {
    const { withdrawAmount } = this.state;
    const { accounts, web3, contractAddress } = this.props;
    if (!withdrawAmount) return;
    await withdrawDai(
      web3,
      accounts[0],
      contractAddress,
      web3.utils.toWei(withdrawAmount, "ether"),
      txHash => {
        this.setState({ txHash, withdrawAmount: "" });
        this.showToasts(txHash);
      }
    );
  };

  handleTransact = async () => {
    const { recipientEmail, sendAmount } = this.state;
    const {
      accounts,
      web3,
      contractAddress,
      getPublicAddress,
      contract
    } = this.props;
    const recipientAddress = await getPublicAddress(recipientEmail);
    console.log("reciever", recipientAddress);
    await transactDai(
      web3,
      accounts[0],
      contractAddress,
      web3.utils.toWei(sendAmount, "ether"),
      recipientAddress,
      txHash => {
        this.showToasts(txHash);
        this.props.showModal();
        contract.events.Reward(
          {
            fromBlock: 0
          },
          function(error, event) {
            if (error) console.log(error);
            console.log("REWARD EVENT:", event);
          }
        );
      }
    );
  };

  handleChange = event => {
    this.setState({ [event.target.name]: event.target.value });
  };

  render() {
    const { addAmount, withdrawAmount, txHash } = this.state;
    console.log("txHash", txHash);
    return (
      <div className="container-fluid mt-4">
        {/* <div className="row justify-content-center pt-5">
          <div className="col-8">
            <div className="card text-dark bg-danger m-auto p-3 shadow">
              <h6 className="text-center">Wallet Balance</h6>
              <h1 className="text-center bold">${balance}</h1>
              <p className="text-center">{accounts && accounts[0]}</p>
            </div>
          </div>
        </div> */}
        <div className="row justify-content-center pt-5">
          <div className="col-6">
            <div className="function-block add text-dark m-auto p-5 shadow border-light">
              <h4 className="text-center">Add Money</h4>
              <input
                className="form-control form-control-lg my-3"
                type="number"
                name="addAmount"
                placeholder="Enter amount in DAI"
                onChange={this.handleChange}
              />
              <button
                type="button"
                className="btn btn-success col-12 btn-lg"
                onClick={this.handleDeposit}
              >
                Add {addAmount ? `${addAmount} DAI` : ""}{" "}
                {/* <span role="img" aria-label="withdraw">
                  &#x1F4B0;&#x1F525;
                </span> */}
              </button>
            </div>
          </div>
          <div className="col-6">
            <div className="function-block withdraw text-dark m-auto p-5 shadow border-light">
              <h4 className="text-center">Withdraw Money</h4>
              <input
                className="form-control form-control-lg my-3"
                type="number"
                name="withdrawAmount"
                placeholder="Enter amount in DAI"
                onChange={this.handleChange}
              />
              <button
                type="button"
                className="btn btn-danger col-12 btn-lg"
                onClick={this.handleWithdraw}
              >
                Withdraw {withdrawAmount ? `${withdrawAmount} DAI ` : " "}
              </button>
            </div>
          </div>
        </div>
        <div className="row justify-content-center pt-5">
          <div className="col-6">
            <div className="function-block send bg-light m-auto p-5 shadow border-light">
              <h4 className="text-center">Send Money</h4>
              <input
                className="form-control form-control-lg my-1"
                type="email"
                name="recipientEmail"
                placeholder="Enter email"
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
                className="btn btn-primary text-center btn-lg col-12"
                onClick={this.handleTransact}
              >
                Send{" "}
              </button>
            </div>
          </div>
          <div className="col-6">
            <div className="function-block text-white send send-info bg-light m-auto p-5 shadow border-light">
              <h4 className="text-center">
                Send more than 10 DAI and get a chance to win a scratch card
                prize upto 1,000 DAI!
              </h4>
            </div>
          </div>
        </div>
        <ToastContainer
          position="top-right"
          autoClose={6000}
          hideProgressBar={false}
          newestOnTop={false}
          closeOnClick={false}
          rtl={false}
          pauseOnVisibilityChange
          draggable
          pauseOnHover
        />
      </div>
    );
  }
}
