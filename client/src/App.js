import React, { Component } from "react";
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
  }
}

export default App;
