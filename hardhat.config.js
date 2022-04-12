require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-solhint");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
require("hardhat-gas-reporter");
require("solidity-coverage");
import "dotenv.config";

// Please set variables in .env file
module.exports = {
  networks: {
    develop: {
      url: "http://localhost:8545",
    },
    /*kovan: {
      url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`0x${process.env.KOVAN_PRIVATE_KEY}`],
      gasMultiplier: 3
    },*/
    coverage: {
      url: "http://localhost:8555"
    }
  },
  solidity: {
    compilers: [{
      version: "0.8.13",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }, {
      version: "0.6.8"
    }, {
      version: "0.5.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }]
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  mocha: {
    timeout: 100000
  }
};