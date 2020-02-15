var Pouch = artifacts.require("./Pouch.sol");

module.exports = function(deployer) {
  deployer.deploy(Pouch, "0x11D456048142671de45A615CFCE12EeE0B2E28A6");
};
