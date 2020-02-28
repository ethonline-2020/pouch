import React from "react";
import "./styles.css";

export default function LeftMenu({ userInfo, totalRewards }) {
  console.log(userInfo);
  if (!userInfo)
    return (
      <div className="left-menu p-3 shadow p-4 text-dark">
        <h1>Pouch</h1>
        <p>Loading...</p>
        <div className="bottom-text">
          <h5>You have logged in through torus.</h5>
          <p>
            Pouch is a peer to peer payments app with an inbuilt reward system
            for transactions, powered by Compound Protocol.
          </p>
        </div>
      </div>
    );
  return (
    <div className="left-menu p-3 shadow p-4 text-dark">
      <h1>Pouch</h1>
      <div>
        <img
          src={userInfo.profileImage}
          className="rounded-circle my-3"
          alt="profile"
          width="100"
        />
      </div>
      <h3 className="text-primary my-4">Hey, {userInfo.name}</h3>
      <h3>Your Total Rewards:</h3>
      <div className="reward-block reward shadow">
        <h1 className="text-center mt-3">
          ${parseFloat(totalRewards).toFixed(2)}{" "}
          <span className="small">PCH</span>
        </h1>
      </div>

      <div className="bottom-text">
        <h5>You have logged in through torus.</h5>
        <p>
          Pouch is a peer to peer payments app with an inbuilt reward system for
          transactions, powered by Compound Protocol.
        </p>
      </div>
    </div>
  );
}
