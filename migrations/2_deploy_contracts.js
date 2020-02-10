var Pouch = artifacts.require("./Pouch.sol");

module.exports = function(deployer) {
  deployer.deploy(Pouch);
};
