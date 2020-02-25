import React from "react";

export default function CreateWallet({ signDaiForDelegate }) {
  return (
    <div className="container">
      <div className="login-block p-4 login-card text-white">
        <div className="text text-center">
          <h1>Create your smart wallet with a single click!</h1>
          <p>Click the button to enable your DAI. It's free!</p>
          <button
            type="button"
            className="btn btn-light text-center btn-lg mx-3"
            onClick={signDaiForDelegate}
          >
            {/* Sign & Permit DAI */}
            Create Wallet
          </button>
        </div>
      </div>
    </div>
  );
}
