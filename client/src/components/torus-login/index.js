import React from "react";
import "./styles.css";

export default function TorusLogin(props) {
  return (
    <div className="container">
      <div className="login-block p-4 login-card text-white">
        <div className="text text-center">
          <h1>Welcome to Pouch</h1>
          <p>Login with Torus using your social media accounts!</p>
          <form onSubmit={props.enableTorus}>
            <button className="btn btn-light col-4 btn-lg">Login</button>
          </form>
        </div>
      </div>
    </div>
  );
}
