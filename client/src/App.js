import React, { Component } from "react";
import Pouch from "./contracts/Pouch.json";
import "./App.css";
import MainApp from "./components/main-app";
import { Switch, Route } from "react-router-dom";

class App extends Component {
  render() {
    return (
      <Switch>
        <Route exact path="/" component={MainApp} />
        {/* <Route exact path="/" component={Login} /> */}
      </Switch>
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
