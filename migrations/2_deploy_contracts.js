// var Pouch = artifacts.require("./Pouch.sol");
// var PouchDelegate = artifacts.require("./PouchDelegate.sol");

// module.exports = async function(deployer) {
//   /*
//   * Step 1: Deploy PouchDelegate
//   * Step 2: Deploy Pouch with address of PouchDelegate as constructor arg
//   * Step 3: Call PouchDelegate.updateLogic with the Pouch contract address
//   */
//  await deployer.deploy(PouchDelegate);
//  const pouchDelegateInstance = await PouchDelegate.deployed();
//  console.log("PouchDelegate deployed at ", pouchDelegateInstance.address);

//  await deployer.deploy(Pouch, pouchDelegateInstance.address);
//  const pouchInstance = await Pouch.deployed();
//  console.log("Pouch contract deployed at: ", pouchInstance.address);
//  await pouchDelegateInstance.updateLogic(pouchInstance.address);
// };

var PouchDelegate = artifacts.require("./PouchDelegate.sol");
module.exports = async function(deployer) {
  /*
   * Step 1: Deploy PouchDelegate
   * Step 2: Deploy Pouch with address of PouchDelegate as constructor arg
   * Step 3: Call PouchDelegate.updateLogic with the Pouch contract address
   */
  await deployer.deploy(PouchDelegate, 42);
  const pouchDelegateInstance = await PouchDelegate.deployed();
  console.log("PouchDelegate deployed at ", pouchDelegateInstance.address);
};
