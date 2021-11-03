# BT4101 BSc Dissertation

## Vibhu Krovvidi



### How To Run

This repository shows the preliminary version of the smart contract used to facilitate the Information System described in the CA report. In order to run this, the following steps must be taken:



1. Install Ganache and Truffle (Ganache is part of the truffle suite)
2. Clone this repository to your computer and start a terminal in the directory
3. Start Ganache either using Ganache CLI or using your terminal
4. Once done, run the command `truffle compile` to compile the smart contract
5. After compilation is successful, run `truffle migrate` to deploy the smart contract to the local development network
6. Next, run `truffle test` to run the unit tests


Note that these instructions create a simulated Ethereum network locally. In practice, a Hyperledger Besu network was initialised and used to conduct smart contract tests.
