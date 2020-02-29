import React from "react";
import Modal from "react-animated-modal";
import "./styles.css";
import TrophyImage from "../../images/trophy.png";

export default function RewardPopup({ show, close }) {
  return (
    <div>
      <Modal visible={show} closemodal={close} type="flipInX">
        <div className="p-4 text-center">
          <img src={TrophyImage} width="100" alt="reward" />
          <h3 className="mt-4">Wohooo! You just won:</h3>
          <h1 className="big mt-3">
            $1.00 <span className="small">PCH</span>
          </h1>
        </div>
      </Modal>
    </div>
  );
}
