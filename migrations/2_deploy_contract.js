const VendingMachine = artifacts.require("VendingMachine3");

module.exports = function (deployer) {
  deployer.deploy(VendingMachine);
};
