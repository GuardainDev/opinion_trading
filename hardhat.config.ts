import { HardhatUserConfig } from 'hardhat/config';
import * as dotenv from 'dotenv';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-etherscan';
import '@openzeppelin/hardhat-upgrades';

import('hardhat-gas-reporter');
dotenv.config();

const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY ?? process.env.DUMMY_PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.19',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          // viaIR: true,
        },
      },
    ],
  },
  networks: {
    Polygon: {
      url: RPC_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: true,
    outputFile: 'gas_report.txt', // remove if the output wamted to printed in terminal
    noColors: true,
    currency: 'USD',
    token: 'MATIC',
    gasPrice: 100,
    coinmarketcap: process.env.COINGECKO_API_KEY,
    //excludeContracts: ['Migrations.sol', 'Wallets/'],
    //onlyCalledMethods: false,
    showTimeSpent: true,
  },
  mocha: {
    timeout: 40000,
  },
};

export default config;
