Rinkeby Testnet Network :-

Crowdsale Contract :- 
https://rinkeby.etherscan.io/address/0xbfca307bc219927baa63018b75268b4e77d8f423#code

QuilHash Token Contract :- 
https://rinkeby.etherscan.io/address/0x0a0f7c76a33ff1503c70fec62292780c15857cce#code

QuillHashPrice Oracle Contract :- (Main Oracle) 
https://rinkeby.etherscan.io/address/0x43c5e074b261fbef5958953e67b4b2f36cad5830#code

QuillHashFallback Oracle Contract :- (Price Update by Client) 
https://rinkeby.etherscan.io/address/0xbff8321d28f08ae235d03c53030ca2be577caa01#code

ETH - USD Oracle contract :- 
https://rinkeby.etherscan.io/address/0x8A753747A1Fa494EC906cE90E9f37563A8AF630e#code

In the document, Some of the points are incorrect and ambiguous.

Reserve Wallet: 30% (20 billion). This one is incorrect exact answer is 15 billion These points are not declared properly. Private sale Duration,PreSale Duration , SoftCap and Bonus So i have developed the smart contract with my own assumption.If anything is wrong kindly let me know.

CrowdSale Features :-

Only Whitelist people can access crowdsale buy function. Whitelist people can only be added by owner. CrowdSale duration is 30 days. Token price is 0.001 USD. Minimum deposit amount is 500 USD. It means, user can buy token given by ETH which is equal to 500 USD. This same flow is applicable for the token transfer. Paused the smart contract,called by the owner to pause, triggers stopped state Unpaused the smart contract,called by the owner to unpause, returns to normal state

Oracle Features :-

ETH - USD price is obtained with the help of oracle contract. Its price cannot be changed by our admin. so the contract of fallback oracle has been put in place to change the ETH-USD price. Admin can decide from which contract to get the ETH-USD price.There are two functions in the priceoracle contract to determine it. Admin has to use the enableChainLink function to get the price from the chainlink. Admin has to use the enableFallbackPriceOracle function to get the price from the fallbackOracle.

Token Features :-

Token total supply is 50 billion. so that no one has this privilege to mint new tokens. All token division is given when the token contract is deployed except crowdsale. Admin has to use the crowdSaleInit function to issued the crowdsale shares.
