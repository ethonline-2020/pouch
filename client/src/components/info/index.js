import React, { Component } from "react";
import "./styles.css";

export default class Dashboard extends Component {
  render() {
    const { accounts, balance, daiBalance } = this.props;
    return (
      <div className="container-fluid">
        <div className="row">
          <div className="col-md-4">
            <div className="info-block address shadow">
              Address
              <h5 className="pt-4">{accounts && accounts[0]}</h5>
            </div>
          </div>
          <div className="col-md-4">
            <div className="info-block pch-balance shadow">
              Pouch Balance
              <h1 className="pt-3">
                ${balance} <span className="small">PCH</span>
              </h1>
            </div>
          </div>
          <div className="col-md-4">
            <div className="info-block dai-balance shadow">
              Dai Balance
              <h1 className="pt-3">
                {parseFloat(daiBalance).toFixed(2)}{" "}
                <span className="small">DAI</span>
              </h1>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
