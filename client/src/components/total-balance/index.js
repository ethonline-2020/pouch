import React, { Component } from "react";

export default class TotalBalance extends Component {
  render() {
    return (
      <div class="container pt-5">
        <div class="row justify-content-center">
          <div class="col-8">
            <div className="card text-white bg-danger m-auto p-3 shadow">
              <h6 className="text-center">Wallet Balance</h6>
              <h1 className="text-center bold">$100</h1>
              <p className="text-center">
                0x5222318905891Ae154c3FA5437830cAA86be5499
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
