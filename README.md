# Solidity Playground

a place to validate some good smart contract ideas

1. [Token Interfaces and Examples](contracts/token)

    1. [Basic ERC20 Interface](contracts/token/ERC20.sol)
    1. [Extended ERC20 Interface](contracts/token/ExtendedERC20.sol), adds symbol, name and decimals
    1. [Basic ERC20 Implementation](contracts/token/ERC20Token.sol), abstract, totalSupply is not defined
    1. [Fixed Supply Token Implementation](contracts/token/FixedERC20.sol), totalSupply is defined
    1. [Configurable Token Implementation](contracts/token/ConfigurableERC20.sol), allows setting symbol, name, decimals and totalSupply upon creation

1. [Crowdsale Examples](contracts/crowdsale)

    A crowdsale is defined by:  
    * offset (required) - crowdsale start, unix timestamp  
    * length (required) - crowdsale length in seconds  
    * price (required) - token price in wei  
    * soft cap (optional) - minimum amount of funds required for crowdsale success, can be zero (if not used)  
    * hard cap (optional) - maximum amount of funds crowdsale can accept, can be zero (unlimited)  
    * quantum (optional) - enables value accumulation effect to reduce value transfer costs, usually is not used (set to zero)  
        * if non-zero value passed specifies minimum amount of wei to transfer to beneficiary  

    Two types of crowdsales are defined:
    1. [Open Crowdsale](contracts/crowdsale/OpenCrowdsale.sol)

        Open crowdsale (aka attached crowdsale) doesn't own tokens and doesn't perform any token emission.  
        It expects enough tokens to be available on its address: these tokens are used for issuing them to investors.  
        Token redemption is done in opposite way: tokens accumulate back on contract's address.  
        Beneficiary is specified by its address.  
        Use this implementation if you need to make several crowdsales with the same token being sold.

    1. Closed Crowdsale
    
        Closed crowdsale owns all the tokens, it guarantees no token emission will occur outside the crowdsale.  
        The tokens created by a crowdsale are used for issuing them to investors.  
        Token redemption is done in opposite way: tokens accumulate back on crowdsale's address.  
        Beneficiary is specified by its address.  
        Use this implementation if you won't have several crowdsales with the same token being sold.
    
1. [Value Sharing Examples](contracts/sharing)

    Let's say you want an ether storage, which is owned by several addresses and you want the ether in the storage
    to be slpit according to their shares.  
    You also want these shares to change depending on amount of ether accumulated inside the storage.  
    How would you achieve this?

    This package contains two possible implementations of the storage:
    
    * [Shared Transfer](contracts/sharing/SharedTransfer.sol)  
        use it if all the addresses are not smart contracts
    * [Shared Accumulator](contracts/sharing/SharedAccumulator.sol)  
        has empty payable function allowing to use it with another smart contracts

1. [Libraries](contracts/lib)

    1. [Transfers](contracts/lib/Transfers.sol)  
        the core of value sharing logic
