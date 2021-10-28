const Cred = artifacts.require("Cred");

module.exports = function(deployer, networks, accounts) {
    deployer.then(() => {
        return deployer.deploy(Cred);
    })
};
