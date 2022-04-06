# BT4101 BSc Dissertation

## Vibhu Krovvidi

### Abstract

The existing credential management system for academic and professional credentials is extremely inefficient, manual and prone to fraud. Verifying credentials is an expensive and time-consuming hassle and it is therefore in the interest of universities, companies and candidates to participate in an information system (IS) that allows for the secure and efficient transfer of credential information. This dissertation describes such an IS which leverages Blockchain Technology, implemented using Hyperledger Besu, to create a decentralised, immutable and secure record of credentials that allows for a self-sovereign identity. Through a smart contract, the actions of each stakeholder are compartmentalised and mechanisms for stakeholders to check each other’s actions are placed. A novel Merkle Tree alignment solution is proposed which prevents tampering of access rights to credentials, offering users greater data security and privacy. Storing pointers to off-chain servers within credentials allows the system to balance the need for immutability with data security and system scalability since no sensitive information is stored on-chain. By passing unit tests simulating legitimate and malicious actions, the system implementation proves it is able to dissuade illegitimate universities and companies aiming to defraud the system’s stakeholders, ensuring a more efficient and trustworthy transfer of credential information between stakeholders.



### Repository Contents

`contracts` contains the Smart Contract [`Cred.sol`](https://github.com/VibhuKrovvidi/Dissertation/blob/main/contracts/Cred.sol) which is the basis of the system design. This file is written in the Solidity programming language and can be used on any EVM running development blockchain. 



`migrations` contains Truffle instructions that tell Truffle how to deploy the smart contract to the relevant blockchain



`test` contains the file [`test_credential.js`](https://github.com/VibhuKrovvidi/Dissertation/blob/main/test/test_credential.js) which contains the detailed test cases that verify if the smart contract and system is acting appropriately.



**This smart contract is designed to run on any EVM blockchain, but has been crafted with <u>Hyperledger Besu</u> in mind**



### How To Run

1. Install Ganache and Truffle (Ganache is part of the truffle suite)
2. Clone this repository to your computer and start a terminal in the directory
3. Start Ganache either using Ganache CLI or using your terminal
4. Once done, run the command `truffle compile` to compile the smart contract
5. After compilation is successful, run `truffle migrate` to deploy the smart contract to the local development network
6. Next, run `truffle test` to run the unit tests

Note that these instructions create a simulated Ethereum network locally. In practice, a Hyperledger Besu network was initialised and used to conduct smart contract tests.



#### System Highlights

| **Objectives**                     | **How This System Achieves Objectives**                      |
| ---------------------------------- | ------------------------------------------------------------ |
| Flexible Credentials               | Credentials follow a single format as shown in  table 3. However, these credentials contain a pointer to the underlying  information rather than the information itself. Through this, the credential  design ensures flexibility for issuing bodies but consistency across the  system. |
| Candidate Ownership                | The smart contract ensures that only credential owners can  control access and sharing of the credentials they receive, as described in  section 4.8. Through this, they can construct a self-sovereign identity using  their credentials. |
| Data Security and Privacy          | The use of blockchain technology coupled with the  use of smart contracts and a consortium network reduce the transparency of  data, allowing privacy to be ensured.     By storing pointers rather than actual data and  using a Merkle Tree solution to prevent tampering of access, the system  ensures a strong sense of privacy and security in all credentials. |
| Minimal Human Input When Verifying | The use of smart contracts allows for automated issuance,  verification and storage of credentials, reducing the human input required to  verify credentials. |
| Scalable and Efficient in Storage  | The use of a consortium ensures data continuity  even if a single university’s systems are down. By storing pointers rather  than underlying data, the storage size of each credential is minimised,  making storage scalable, efficient and fast. |



### System Stakeholders

The stakeholders of the propsed system are:

- Universities
- Companies
- Candidates



The Smart Contract orchestrates and facilitates the transfer of educational and professional credentials across these stakeholders.



### References

Please refer to the accompanying Dissertation Report and Dissertation Slide Deck for greater information on works cited.





`

