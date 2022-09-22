const Satta = artifacts.require("Satta");
const CryptoEGameBetting = artifacts.require("CryptoEGameBetting");

module.exports = async function(deployer) {
  await deployer.deploy(Satta);
  const satta = await Satta.deployed();

  await deployer.deploy(CryptoEGameBetting, satta.address, "4AUFMvQbjLwRnnuM5NLQqVwj8WPu-wQgNssRZjpV9WDDjnvNI68");
  const cryptoEGameBetting = await CryptoEGameBetting.deployed();
};
