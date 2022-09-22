# Battle Arena

<br/>
<p align="center">
<a href="" target="">
<img src="https://github.com/Arashi-H/battle-arena-betting-/blob/develop/Logo.jpeg" width="225" alt="Battle Arena">
</a>
</p>
<br/>

Battle Arena allows gaming enthusiants (and even non gaming enthusuasists) to bet on their favourite professional teams paprticipating in World Tournamnets in a single button!

# Description

Battle Arena is a decentralized platform where users can place bets on World Tounaments. A bet can be placed for a fixed amout of SATTA tokens, which is the native Token of our platform. We will introduce the feature to provide rare match NFTs to our user. Stats regarding the match and probabilty of winning for each will also be provided to user in next version.

# Architecture:


## Front End: 

The front of the Dapp is built using React and Moralis helped us so much with communicating with our smart contract through their SDK. 

## Smart Contracts:

There are 3 smart contracts:
### 1. CryptoEGameBetting.sol

This is the main working contract for the app. Different parts of the contracts are:
- placeBet - Public function used to place bets for a particular match
- checkAndDistributeRewards - Public function to check if match has ended and distribute rewards to the participants based on the results. Only owner of the DApp can call this function
- distributeRewards - Public function called by oracle node with requestId and result
- getMatch -  Public function to get details about a match given a match Id

### 2. OracleClient.sol:

This contract configures the DApp to connect with an oracle node to get results of the match in a decentralized match. 

### 3. Satta.sol:

This is the ERC20 token contract used by platform users to bet on their teams. 

## Backend:

We're using React, with Moralis and Chainlink on the Ethereum Kovan blockchain, to create the project. All the smart contracts are written in Solidity. All most of the match data is stored on chain as currently it is only text data. I have created a token ‘SAT’ for our Dapp which is a native ERC20 token for ‘Battle Arena’ used for betting on different matches. (In future we are planning to introduce Liquidity Pools for our token in Uniswap from where a user can swap MATIC token for SAT). 

I have used chainlink for leveraging off-chain computation offered by it. The Chainlink oracle calls the API of ‘pandascore.co’ to retrieve the live matches of all the supported eGames. The API is called everytime a new Game is clicked by the user for getting the live matches of that game. When the user places a bet on a game he needs to sign two transactions (first for providing the allowance to contract to take SAT tokens from his wallet and the next for signing the transaction of transfer of SAT tokens). The amount of bet is fixed currently (10 SAT tokens) but in future I will provide the functionality to provide the place custom bets.   (In future we will build our own chainlink oracle)



# Installation
-  Clone this Repo:
    ```
    git clone https://github.com/Arashi-H/battle-arena-betting-.git
    ```

-   Install all dependencies:

    ```
    cd battle-arena/
    yarn install
    ```

- Run the Code on localHost:3000:
    ```
    yarn start
    ``` 
## Security Considerations

-   The Repository is currently not audited and is only meant for testing purposes on Testnets (Kovan TestNet)

## TODO/Areas For Improvement
- Liquidity & Farm pools for SATTA token : These pools should facilitate initial distribution of SATTA token among SATTA stakers and provide a way for users to buy SATTA token using native tokens
- Air drops of SATTA token : This should faciliate in motivating users to onboard to our platform
- Oracle node : Currently we are using existing api's and oracle nodes, in future we would like to use The graph protocol with custom api's to get better data to our DApp
- DAO : We would like to use the concept of DAO for future improvements in contract using SATTA as governance token
- Backend logic : Currently our betting algorithm is very simplified owing to timing constraints, in future we want to make the algorithm more interesting for our users
- IPFS : In future we want to use IPFS technology to host our UI in decentralized environment
- Write Tests : We would like to safe gaurd out DApp with more tests
