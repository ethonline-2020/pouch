import React from "react";
import Info from "../../components/info";
import LeftMenu from "../../components/left-menu";
import Functions from "../../components/functions";
export default function PouchApp(props) {
  return (
    <div className="container-fluid">
      <div className="row">
        <div className="col-3">
          <LeftMenu />
        </div>
        <div className="col-9">
          <Info {...props} />
          <Functions {...props} />
        </div>
      </div>
    </div>
  );
}
