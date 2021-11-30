require("@nomiclabs/hardhat-waffle"); //为导入的插件
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.3",
  networks: {
    // rinkeby: {
    //   url: "https://rinkeby.infura.io/v3/0850b21599f24001807c06cfc359a9f1", //Infura url with projectId
    //   accounts: ["a046e74b8ab340e4ab972098273b0bcf"] // add the account that will deploy the contract (private key)
    // },
  }
};
