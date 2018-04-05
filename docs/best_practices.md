# Ethereum Smart Contract Security Best Practices

This document provides a baseline knowledge of security considerations for intermediate Solidity programmers. It is maintained by [ConsenSys Diligence](https://media.consensys.net/introducing-consensys-diligence-cf38f83948c), and the broader Ethereum community.

[![Join the chat at https://gitter.im/ConsenSys/smart-contract-best-practices](https://badges.gitter.im/ConsenSys/smart-contract-best-practices.svg)](https://gitter.im/ConsenSys/smart-contract-best-practices?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Where to start?

* [General Philosopy](#general-philosopy) describes the smart contract security mindset
* [Solidity Recommendations](#solidity-recommendations) contains examples of good code patterns
* [Known Attacks](#known-attacks) describes the different classes of vulnerabilities to avoid
* [Software Engineering](#software-engineering) outlines some architectural and design approaches for risk mitigation
* [Documentation and Procedures](#documentation-and-procedures) outlines best practices for documenting your system for other developers and auditors 
* [Security Tools](#security-tools) lists tools for improving code quality, and detecting vulnerabilities
* [Security Notifications](#security-notifications) lists sources of information for staying up to date
* [Tokens](#tokens) outlines best practices specifically related to Tokens.

## Contributions are welcome!

Feel free to submit a pull request, with anything from small fixes, to full new sections. If you are writing new content, please reference the [contributing](https://github.com/ConsenSys/smart-contract-best-practices/about/contributing.md) page for guidance on style. 

See the [issues](https://github.com/ConsenSys/smart-contract-best-practices/issues) for topics that need to be covered or updated. If you have an idea you'd like to discuss, please chat with us in [Gitter](https://gitter.im/ConsenSys/smart-contract-best-practices).

If you've written an article or blog post, please add it to the [bibliography](https://github.com/ConsenSys/smart-contract-best-practices/bibliography.md).  


#General Philosopy

Ethereum and complex blockchain programs are new and highly experimental. Therefore, you should expect constant changes in the security landscape, as new bugs and security risks are discovered, and new best practices are developed. Following the security practices in this document is therefore only the beginning of the security work you will need to do as a smart contract developer.

Smart contract programming requires a different engineering mindset than you may be used to. The cost of failure can be high, and change can be difficult, making it in some ways more similar to hardware programming or financial services programming than web or mobile development. It is therefore not enough to defend against known vulnerabilities. Instead, you will need to learn a new philosophy of development:

## Prepare for failure

Any non-trivial contract will have errors in it. Your code must, therefore, be able to respond to bugs and vulnerabilities gracefully.

  - Pause the contract when things are going wrong ('circuit breaker')
  - Manage the amount of money at risk (rate limiting, maximum usage)
  - Have an effective upgrade path for bugfixes and improvements

## Rollout carefully

It is always better to catch bugs before a full production release.
  - Test contracts thoroughly, and add tests whenever new attack vectors are discovered
  - Provide [bug bounties](#bounties) starting from alpha testnet releases
  - Rollout in phases, with increasing usage and testing in each phase

## Keep contracts simple

Complexity increases the likelihood of errors.

  - Ensure the contract logic is simple
  - Modularize code to keep contracts and functions small
  - Use already-written tools or code where possible (eg. don't roll your own random number generator)
  - Prefer clarity to performance whenever possible
  - Only use the blockchain for the parts of your system that require decentralization

## Stay up to date

Use the resources listed in the next section to keep track of new security developments.

  - Check your contracts for any new bug that's discovered
  - Upgrade to the latest version of any tool or library as soon as possible
  - Adopt new security techniques that appear useful

## Be aware of blockchain properties

While much of your programming experience will be relevant to Ethereum programming, there are some pitfalls to be aware of.

  - Be extremely careful about external contract calls, which may execute malicious code and change control flow.
  - Understand that your public functions are public, and may be called maliciously. Your private data is also viewable by anyone.
  - Keep gas costs and the block gas limit in mind.

## Fundamental Tradeoffs: Simplicity versus Complexity cases

There are multiple fundamental tradeoffs to consider when assessing the structure and security of a smart contract system.  The general recommendation for any smart contract system is to identify the proper balance for these fundamental tradeoffs.

An ideal smart contract system from a software engineering bias is modular, reuses code instead of duplicating it, and supports upgradeable components.  An ideal smart contract system from a secure architecture bias may share this mindset, especially in the case of more complex smart contract systems.

However, there are important exceptions where security and software engineering best practices may not be aligned.  In each case, the proper balance is obtained by identifying the optimal mix of properties along contract system dimensions such as:

- Rigid versus Upgradeable
- Monolithic versus Modular
- Duplication versus Reuse

### Rigid versus Upgradeable

While multiple resources, including this one, emphasize malleability characteristics such as Killable, Upgradeable or Modifiable patterns there is a *fundamental tradeoff* between malleability and security.

Malleability patterns by definition add complexity and potential attack surfaces.  Simplicity is particularly effective over complexity in cases where the smart contract system performs a very limited set of functionality for a pre-defined limited period of time, for example, a governance-free finite-time-frame token-sale contract system.

### Monolithic versus Modular

A monolithic self-contained contract keeps all knowledge locally identifiable and readable.  While there are few smart contract systems held in high regard that exist as monoliths, there is an argument to be made for extreme locality of data and flow - for example, in the case of optimizing code review efficiency.

As with the other tradeoffs considered here, security best practices trend away from software engineering best practices in simple short-lived contracts and trend toward software engineering best practices in the case of more complex perpetual contract systems.

### Duplication versus Reuse

A smart contract system from a software engineering perspective wishes to maximize reuse where reasonable.  There are many ways to reuse contract code in Solidity.  Using proven previously-deployed contracts *which you own* is generally the safest manner to achieve code reuse.

Duplication is frequently relied upon in cases where self-owned previously-deployed contracts are not available.  Efforts such as [Live Libs](https://github.com/ConsenSys/live-libs) and [Zeppelin Solidity](https://github.com/OpenZeppelin/zeppelin-solidity) seek to provide patterns such that secure code can be re-used without duplication.  Any contract security analyses must include any re-used code that has not previously established a level of trust commensurate with the funds at risk in the target smart contract system.


#Solidity Recommendations

This page demonstrates a number of solidity patterns which should generally be followed when writing smart contracts.

## Protocol specific recommendations

### <!-- -->

The following recommendations apply to the development of any contract system on Ethereum.

## External Calls

### Use caution when making external calls

Calls to untrusted contracts can introduce several unexpected risks or errors. External calls may execute malicious code in that contract _or_ any other contract that it depends upon. As such, every external call should be treated as a potential security risk. When it is not possible, or undesirable to remove external calls, use the recommendations in the rest of this section to minimize the danger.

### Mark untrusted contracts

When interacting with external contracts, name your variables, methods, and contract interfaces in a way that makes it clear that interacting with them is potentially unsafe. This applies to your own functions that call external contracts.

```sol
// bad
Bank.withdraw(100); // Unclear whether trusted or untrusted

function makeWithdrawal(uint amount) { // Isn't clear that this function is potentially unsafe
    Bank.withdraw(amount);
}

// good
UntrustedBank.withdraw(100); // untrusted external call
TrustedBank.withdraw(100); // external but trusted bank contract maintained by XYZ Corp

function makeUntrustedWithdrawal(uint amount) {
    UntrustedBank.withdraw(amount);
}
```


### Avoid state changes after external calls

Whether using *raw calls* (of the form `someAddress.call()`) or *contract calls* (of the form `ExternalContract.someMethod()`), assume that malicious code might execute. Even if `ExternalContract` is not malicious, malicious code can be executed by any contracts *it* calls. 

One particular danger is malicious code may hijack the control flow, leading to race conditions. (See [Race Conditions](#race-conditions) for a fuller discussion of this problem).

If you are making a call to an untrusted external contract, *avoid state changes after the call*. This pattern is also sometimes known as the [checks-effects-interactions pattern](http://solidity.readthedocs.io/en/develop/security-considerations.html?highlight=check%20effects#use-the-checks-effects-interactions-pattern).


### Be aware of the tradeoffs between `send()`, `transfer()`, and `call.value()()`

When sending ether be aware of the relative tradeoffs between the use of
`someAddress.send()`, `someAddress.transfer()`, and `someAddress.call.value()()`.

- `someAddress.send()`and `someAddress.transfer()` are considered *safe* against [reentrancy](#reentrancy).
    While these methods still trigger code execution, the called contract is
    only given a stipend of 2,300 gas which is currently only enough to log an
    event.
- `x.transfer(y)` is equivalent to `require(x.send(y));`, it will automatically revert if the send fails.
- `someAddress.call.value(y)()` will send the provided ether and trigger code execution.  
    The executed code is given all available gas for execution making this type of value transfer *unsafe* against reentrancy.

Using `send()` or `transfer()` will prevent reentrancy but it does so at the cost of being incompatible with any contract whose fallback function requires more than 2,300 gas. It is also possible to use `someAddress.call.value(ethAmount).gas(gasAmount)()` to forward a custom amount of gas.

One pattern that attempts to balance this trade-off is to implement both
a [*push* and *pull*](#favor-pull-over-push-for-external-calls) mechanism, using `send()` or `transfer()`
for the *push* component and `call.value()()` for the *pull* component.

It is worth pointing out that exclusive use of `send()` or `transfer()` for value transfers
does not itself make a contract safe against reentrancy but only makes those
specific value transfers safe against reentrancy.


### Handle errors in external calls

Solidity offers low-level call methods that work on raw addresses: `address.call()`, `address.callcode()`, `address.delegatecall()`, and `address.send()`. These low-level methods never throw an exception, but will return `false` if the call encounters an exception. On the other hand, *contract calls* (e.g., `ExternalContract.doSomething()`) will automatically propagate a throw (for example, `ExternalContract.doSomething()` will also `throw` if `doSomething()` throws).

If you choose to use the low-level call methods, make sure to handle the possibility that the call will fail, by checking the return value.

```sol
// bad
someAddress.send(55);
someAddress.call.value(55)(); // this is doubly dangerous, as it will forward all remaining gas and doesn't check for result
someAddress.call.value(100)(bytes4(sha3("deposit()"))); // if deposit throws an exception, the raw call() will only return false and transaction will NOT be reverted

// good
if(!someAddress.send(55)) {
    // Some failure code
}

ExternalContract(someAddress).deposit.value(100);
```


### Favor *pull* over *push* for external calls

External calls can fail accidentally or deliberately. To minimize the damage caused by such failures, it is often better to isolate each external call into its own transaction that can be initiated by the recipient of the call. This is especially relevant for payments, where it is better to let users withdraw funds rather than push funds to them automatically. (This also reduces the chance of [problems with the gas limit](#dos-with-block-gas-limit).)  Avoid combining multiple `send()` calls in a single transaction.

```sol
// bad
contract auction {
    address highestBidder;
    uint highestBid;

    function bid() payable {
        require(msg.value >= highestBid);

        if (highestBidder != 0) {
            highestBidder.transfer(highestBid); // if this call consistently fails, no one else can bid
        }

       highestBidder = msg.sender;
       highestBid = msg.value;
    }
}

// good
contract auction {
    address highestBidder;
    uint highestBid;
    mapping(address => uint) refunds;

    function bid() payable external {
        require(msg.value >= highestBid);

        if (highestBidder != 0) {
            refunds[highestBidder] += highestBid; // record the refund that this user can claim
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdrawRefund() external {
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        msg.sender.transfer(refund);
    }
}
```

## Don't assume contracts are created with zero balance

An attacker can send wei to the address of a contract before it is created.  Contracts should not assume that its initial state contains a zero balance.  See [issue 61](https://github.com/ConsenSys/smart-contract-best-practices/issues/61) for more details.

## Remember that on-chain data is public

Many applications require submitted data to be private up until some point in time in order to work. Games (eg. on-chain rock-paper-scissors) and auction mechanisms (eg. sealed-bid second-price auctions) are two major categories of examples. If you are building an application where privacy is an issue, take care to avoid requiring users to publish information too early.

Examples:

* In rock paper scissors, require both players to submit a hash of their intended move first, then require both players to submit their move; if the submitted move does not match the hash throw it out.
* In an auction, require players to submit a hash of their bid value in an initial phase (along with a deposit greater than their bid value), and then submit their action bid value in the second phase.
* When developing an application that depends on a random number generator, the order should always be (1) players submit moves, (2) random number generated, (3) players paid out. The method by which random numbers are generated is itself an area of active research; current best-in-class solutions include Bitcoin block headers (verified through http://btcrelay.org), hash-commit-reveal schemes (ie. one party generates a number, publishes its hash to "commit" to the value, and then reveals the value later) and [RANDAO](http://github.com/randao/randao).
* If you are implementing a frequent batch auction, a hash-commit scheme is also desirable.

## In 2-party or N-party contracts, beware of the possibility that some participants may "drop offline" and not return

Do not make refund or claim processes dependent on a specific party performing a particular action with no other way of getting the funds out. For example, in a rock-paper-scissors game, one common mistake is to not make a payout until both players submit their moves; however, a malicious player can "grief" the other by simply never submitting their move - in fact, if a player sees the other player's revealed move and determines that they lost, they have no reason to submit their own move at all. This issue may also arise in the context of state channel settlement. When such situations are an issue, (1) provide a way of circumventing non-participating participants, perhaps through a time limit, and (2) consider adding an additional economic incentive for participants to submit information in all of the situations in which they are supposed to do so.

## Solidity specific recommendations

### <!-- -->

The following recommendations are specific to Solidity, but may also be instructive for developing smart contracts in other languages.

## Enforce invariants with `assert()`

An assert guard triggers when an assertion fails - such as an invariant property changing. For example, the token to ether issuance ratio, in a token issuance contract, may be fixed. You can verify that this is the case at all times with an `assert()`. Assert guards should often be combined with other techniques, such as pausing the contract and allowing upgrades. (Otherwise, you may end up stuck, with an assertion that is always failing.)

Example:

```sol
contract Token {
    mapping(address => uint) public balanceOf;
    uint public totalSupply;

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        assert(this.balance >= totalSupply);
    }
}
```

Note that the assertion is *not* a strict equality of the balance because the contract can be [forcibly sent ether](#remember-that-ether-can-be-forcibly-sent-to-an-account) without going through the `deposit()` function!


## Use `assert()` and `require()` properly

In Solidity 0.4.10 `assert()` and `require()` were introduced. `require(condition)` is meant to be used for input validation, which should be done on any user input, and reverts if the condition is false. `assert(condition)` also reverts if the condition is false but should be used only for invariants: internal errors or to check if your contract has reached an invalid state. Following this paradigm allows formal analysis tools to verify that the invalid opcode can never be reached: meaning no invariants in the code are violated and that the code is formally verified.

## Beware rounding with integer division

All integer division rounds down to the nearest integer. If you need more precision, consider using a multiplier, or store both the numerator and denominator.

(In the future, Solidity will have a fixed-point type, which will make this easier.)

```sol
// bad
uint x = 5 / 2; // Result is 2, all integer divison rounds DOWN to the nearest integer
```

Using a multiplier prevents rounding down, this multiplier needs to be accounted for when working with x in the future:

```sol
// good
uint multiplier = 10;
uint x = (5 * multiplier) / 2;
```

Storing the numerator and denominator means you can calculate the result of `numerator/denominator` off-chain:
```sol
// good
uint numerator = 5;
uint denominator = 2;
```

## Remember that Ether can be forcibly sent to an account

Beware of coding an invariant that strictly checks the balance of a contract.

An attacker can forcibly send wei to any account and this cannot be prevented (not even with a fallback function that does a `revert()`).

The attacker can do this by creating a contract, funding it with 1 wei, and invoking
`selfdestruct(victimAddress)`.  No code is invoked in `victimAddress`, so it
cannot be prevented.

## Be aware of the tradeoffs between abstract contracts and interfaces

Both interfaces and abstract contracts provide one with a customizable and re-usable approach for smart contracts. Interfaces, which were introduced in Solidity 0.4.11, are similar to abstract contracts but cannot have any functions implemented. Interfaces also have limitations such as not being able to access storage or inherit from other interfaces which generally makes abstract contracts more practical. Although, interfaces are certainly useful for designing contracts prior to implementation. Additionally, it is important to keep in mind that if a contract inherits from an abstract contract it must implement all non-implemented functions via overriding or it will be abstract as well.

## Keep fallback functions simple

[Fallback functions](http://solidity.readthedocs.io/en/latest/contracts.html#fallback-function) are called when a contract is sent a message with no arguments (or when no function matches), and only has access to 2,300 gas when called from a `.send()` or `.transfer()`. If you wish to be able to receive Ether from a `.send()` or `.transfer()`, the most you can do in a fallback function is log an event. Use a proper function if a computation or more gas is required.

```sol
// bad
function() payable { balances[msg.sender] += msg.value; }

// good
function deposit() payable external { balances[msg.sender] += msg.value; }

function() payable { LogDepositReceived(msg.sender); }
```

## Explicitly mark visibility in functions and state variables

Explicitly label the visibility of functions and state variables. Functions can be specified as being `external`, `public`, `internal` or `private`. Please understand the differences between them, for example, `external` may be sufficient instead of `public`. For state variables, `external` is not possible. Labeling the visibility explicitly will make it easier to catch incorrect assumptions about who can call the function or access the variable.

```sol
// bad
uint x; // the default is internal for state variables, but it should be made explicit
function buy() { // the default is public
    // public code
}

// good
uint private y;
function buy() external {
    // only callable externally
}

function utility() public {
    // callable externally, as well as internally: changing this code requires thinking about both cases.
}

function internalAction() internal {
    // internal code
}
```

## Lock pragmas to specific compiler version

Contracts should be deployed with the same compiler version and flags that they have been tested the most with. Locking the pragma helps ensure that contracts do not accidentally get deployed using, for example, the latest compiler which may have higher risks of undiscovered bugs. Contracts may also be deployed by others and the pragma indicates the compiler version intended by the original authors.

```sol
// bad
pragma solidity ^0.4.4;


// good
pragma solidity 0.4.4;
```

### Exception

Pragma statements can be allowed to float when a contract is intended for consumption by other developers, as in the case with contracts in a library or EthPM package. Otherwise, the developer would need to manually update the pragma in order to compile locally. 

## Differentiate functions and events

Favor capitalization and a prefix in front of events (we suggest *Log*), to prevent the risk of confusion between functions and events. For functions, always start with a lowercase letter, except for the constructor.

```sol
// bad
event Transfer() {}
function transfer() {}

// good
event LogTransfer() {}
function transfer() external {}
```

## Prefer newer Solidity constructs

Prefer constructs/aliases such as `selfdestruct` (over `suicide`) and `keccak256` (over `sha3`).  Patterns like `require(msg.sender.send(1 ether))` can also be simplified to using `transfer()`, as in `msg.sender.transfer(1 ether)`.

## Be aware that 'Built-ins' can be shadowed

It is currently possible to [shadow](https://en.wikipedia.org/wiki/Variable_shadowing) built-in globals in Solidity. This allows contracts to override the functionality of built-ins such as `msg` and `revert()`. Although this [is intended](https://github.com/ethereum/solidity/issues/1249), it can mislead users of a contract as to the contract's true behavior.

```sol
contract PretendingToRevert {
    function revert() internal constant {}
}

contract ExampleContract is PretendingToRevert {
    function somethingBad() public {
        revert();
    }
}
```

Contract users (and auditors) should be aware of the full smart contract source code of any application they intend to use. 

## Avoid using `tx.origin`

Never use `tx.origin` for authorization, another contract can have a method which will call your contract (where the user has some funds for instance) and your contract will authorize that transaction as your address is in `tx.origin`.

```
pragma solidity 0.4.18;

contract MyContract {

    address owner;
    
    function MyContract() public {
        owner = msg.sender;
    }
    
    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }
    
}

contract AttackingContract {

    MyContract myContract;
    address attacker;

    function AttackingContract(address myContractAddress) public {
        myContract = MyContract(myContractAddress);
        attacker = msg.sender;
    }

    function() public {
        myContract.sendTo(attacker, msg.sender.balance);
    }
    
}
```

You should use `msg.sender` for authorization (if another contract calls your contract `msg.sender` will be the address of the contract and not the address of the user who called the contract).

You can read more about it here: [Solidity docs](https://solidity.readthedocs.io/en/develop/security-considerations.html#tx-origin)

Besides the issue with authorization, there is a chance that `tx.origin` will be removed from the Ethereum protocol in the future, so code that uses `tx.origin` won't be compatible with future releases [Vitalik: 'Do NOT assume that tx.origin will continue to be usable or meaningful.'](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof/200#200)

It's also worth mentioning that by using `tx.origin` you're limiting interoperability between contracts because the contract that uses tx.origin cannot be used by another contract as a contract can't be the `tx.origin`.

## Timestamp Dependence

There are three main considerations when using a timestamp to execute a critical function in a contract, especially when actions involve fund transfer.

### Gameability

Be aware that the timestamp of the block can be manipulated by a miner. Consider this [contract](https://etherscan.io/address/0xcac337492149bdb66b088bf5914bedfbf78ccc18#code):

```sol
    
uint256 constant private salt =  block.timestamp;
    
function random(uint Max) constant private returns (uint256 result){
    //get the best seed for randomness
    uint256 x = salt * 100/Max;
    uint256 y = salt * block.number/(salt % 5) ;
    uint256 seed = block.number/3 + (salt % 300) + Last_Payout + y; 
    uint256 h = uint256(block.blockhash(seed)); 
    
    return uint256((h / x)) % Max + 1; //random number between 1 and Max
}
```

When the contract uses the timestamp to seed a random number, the miner can actually post a timestamp within 30 seconds of the block being validating, effectively allowing the miner to precompute an option more favorable to their chances in the lottery. Timestamps are not random and should not be used in that context.

### *30-second Rule*
A general rule of thumb in evaluating timestamp usage is:
#### If the contract function can tolerate a [30-second](https://ethereum.stackexchange.com/questions/5924/how-do-ethereum-mining-nodes-maintain-a-time-consistent-with-the-network/5931#5931) drift in time, it is safe to use `block.timestamp`
If the scale of your time-dependent event can vary by 30-seconds and maintain integrity, it is safe to use a timestamp. This includes things like ending of auctions, registration periods, etc. 

### Caution using `block.number` as a timestamp

When a contract creates an `auction_complete` modifier to signify the end of a token sale such as [so]((https://github.com/SpankChain/old-sc_auction/blob/master/contracts/Auction.sol))
```sol
modifier auction_complete {
    require(auctionEndBlock <= block.number     ||
          currentAuctionState == AuctionState.success || 
          currentAuctionState == AuctionState.cancel)
        _;}
```
`block.number` and *[average block time](https://etherscan.io/chart/blocktime)* can be used to estimate time as well, but this is not future proof as block times may change (such as [fork reorganisations](https://blog.ethereum.org/2015/08/08/chain-reorganisation-depth-expectations/) and the [difficulty bomb](https://github.com/ethereum/EIPs/issues/649)). In a sale spanning days, the 12-minute rule allows one to construct a more reliable estimate of time. 

## Multiple Inheritance Caution

When utilizing multiple inheritance in Solidity, it is important to understand how the compiler composes the inheritance graph.

```sol

contract Final {
    uint public a;
    function Final(uint f) public {
        a = f;
    }
}

contract B is Final {
    int public fee;
    
    function B(uint f) Final(f) public {
    }
    function setFee() public {
        fee = 3;
    }
}

contract C is Final {
    int public fee;
    
    function C(uint f) Final(f) public {
    }
    function setFee() public {
        fee = 5;
    }
}

contract A is B, C {
  function A() public B(3) C(5) {
      setFee();
  }
}
```
When A is deployed, the compiler will *linearize* the inheritance from left to right, as:

**C -> B -> A**

The consequence of the linearization will yield a `fee` value of 5, since C is the most derived contract. This may seem obvious, but imagine scenarios where C is able to shadow crucial functions, reorder boolean clauses, and cause the developer to write exploitable contracts. Static analysis currently does not raise issue with overshadowed functions, so it must be manually inspected.

For more on security and inheritance, check out this [article](https://pdaian.com/blog/solidity-anti-patterns-fun-with-inheritance-dag-abuse/)

To help contribute, Solidity's Github has a [project](https://github.com/ethereum/solidity/projects/9#card-8027020) with all inheritance-related issues.

## Deprecated/historical recommendations

These are recommendations which are no longer relevant due to changes in the protocol or improvements to solidity. They are recorded here for posterity and awareness. 

### Beware division by zero (Solidity < 0.4)

Prior to version 0.4, Solidity [returns zero](https://github.com/ethereum/solidity/issues/670) and does not `throw` an exception when a number is divided by zero. Ensure you're running at least version 0.4.


#Known Attacks

The following is a list of known attacks which you should be aware of, and defend against when writing smart contracts.

## Race Conditions<sup><a href='#footnote-race-condition-terminology'>\*</a></sup>

One of the major dangers of calling external contracts is that they can take over the control flow, and make changes to your data that the calling function wasn't expecting. This class of bug can take many forms, and both of the major bugs that led to the DAO's collapse were bugs of this sort.

### Reentrancy

The first version of this bug to be noticed involved functions that could be called repeatedly, before the first invocation of the function was finished. This may cause the different invocations of the function to interact in destructive ways.

```sol
// INSECURE
mapping (address => uint) private userBalances;

function withdrawBalance() public {
    uint amountToWithdraw = userBalances[msg.sender];
    require(msg.sender.call.value(amountToWithdraw)()); // At this point, the caller's code is executed, and can call withdrawBalance again
    userBalances[msg.sender] = 0;
}
```

Since the user's balance is not set to 0 until the very end of the function, the second (and later) invocations will still succeed, and will withdraw the balance over and over again. A very similar bug was one of the vulnerabilities in the DAO attack.

In the example given, the best way to avoid the problem is to [use `send()` instead of `call.value()()`](#send-vs-call-value). This will prevent any external code from being executed.

However, if you can't remove the external call, the next simplest way to prevent this attack is to make sure you don't call an external function until you've done all the internal work you need to do:

```sol
mapping (address => uint) private userBalances;

function withdrawBalance() public {
    uint amountToWithdraw = userBalances[msg.sender];
    userBalances[msg.sender] = 0;
    require(msg.sender.call.value(amountToWithdraw)()); // The user's balance is already 0, so future invocations won't withdraw anything
}
```

Note that if you had another function which called `withdrawBalance()`, it would be potentially subject to the same attack, so you must treat any function which calls an untrusted contract as itself untrusted. See below for further discussion of potential solutions.

### Cross-function Race Conditions

An attacker may also be able to do a similar attack using two different functions that share the same state.

```sol
// INSECURE
mapping (address => uint) private userBalances;

function transfer(address to, uint amount) {
    if (userBalances[msg.sender] >= amount) {
       userBalances[to] += amount;
       userBalances[msg.sender] -= amount;
    }
}

function withdrawBalance() public {
    uint amountToWithdraw = userBalances[msg.sender];
    require(msg.sender.call.value(amountToWithdraw)()); // At this point, the caller's code is executed, and can call transfer()
    userBalances[msg.sender] = 0;
}
```

In this case, the attacker calls `transfer()` when their code is executed on the external call in `withdrawBalance`. Since their balance has not yet been set to 0, they are able to transfer the tokens even though they already received the withdrawal. This vulnerability was also used in the DAO attack.

The same solutions will work, with the same caveats. Also note that in this example, both functions were part of the same contract. However, the same bug can occur across multiple contracts, if those contracts share state.

### Pitfalls in Race Condition Solutions

Since race conditions can occur across multiple functions, and even multiple contracts, any solution aimed at preventing reentry will not be sufficient.

Instead, we have recommended finishing all internal work first, and only then calling the external function. This rule, if followed carefully, will allow you to avoid race conditions. However, you need to not only avoid calling external functions too soon, but also avoid calling functions which call external functions. For example, the following is insecure:

```sol
// INSECURE
mapping (address => uint) private userBalances;
mapping (address => bool) private claimedBonus;
mapping (address => uint) private rewardsForA;

function withdraw(address recipient) public {
    uint amountToWithdraw = userBalances[recipient];
    rewardsForA[recipient] = 0;
    require(recipient.call.value(amountToWithdraw)());
}

function getFirstWithdrawalBonus(address recipient) public {
    require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

    rewardsForA[recipient] += 100;
    withdraw(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
    claimedBonus[recipient] = true;
}
```

Even though `getFirstWithdrawalBonus()` doesn't directly call an external contract, the call in `withdraw()` is enough to make it vulnerable to a race condition. You therefore need to treat `withdraw()` as if it were also untrusted.

```sol
mapping (address => uint) private userBalances;
mapping (address => bool) private claimedBonus;
mapping (address => uint) private rewardsForA;

function untrustedWithdraw(address recipient) public {
    uint amountToWithdraw = userBalances[recipient];
    rewardsForA[recipient] = 0;
    require(recipient.call.value(amountToWithdraw)());
}

function untrustedGetFirstWithdrawalBonus(address recipient) public {
    require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

    claimedBonus[recipient] = true;
    rewardsForA[recipient] += 100;
    untrustedWithdraw(recipient); // claimedBonus has been set to true, so reentry is impossible
}
```

In addition to the fix making reentry impossible, [untrusted functions have been marked](#mark-untrusted-contracts). This same pattern repeats at every level: since `untrustedGetFirstWithdrawalBonus()` calls `untrustedWithdraw()`, which calls an external contract, you must also treat `untrustedGetFirstWithdrawalBonus()` as insecure.

Another solution often suggested is a [mutex](https://en.wikipedia.org/wiki/Mutual_exclusion). This allows you to "lock" some state so it can only be changed by the owner of the lock. A simple example might look like this:

```sol
// Note: This is a rudimentary example, and mutexes are particularly useful where there is substantial logic and/or shared state
mapping (address => uint) private balances;
bool private lockBalances;

function deposit() payable public returns (bool) {
    require(!lockBalances);
    lockBalances = true;
    balances[msg.sender] += msg.value;
    lockBalances = false;
    return true;
}

function withdraw(uint amount) payable public returns (bool) {
    require(!lockBalances && amount > 0 && balances[msg.sender] >= amount);
    lockBalances = true;

    if (msg.sender.call(amount)()) { // Normally insecure, but the mutex saves it
      balances[msg.sender] -= amount;
    }

    lockBalances = false;
    return true;
}
```

If the user tries to call `withdraw()` again before the first call finishes, the lock will prevent it from having any effect. This can be an effective pattern, but it gets tricky when you have multiple contracts that need to cooperate. The following is insecure:

```sol
// INSECURE
contract StateHolder {
    uint private n;
    address private lockHolder;

    function getLock() {
        require(lockHolder == 0);
        lockHolder = msg.sender;
    }

    function releaseLock() {
        require(msg.sender == lockHolder);
        lockHolder = 0;
    }

    function set(uint newState) {
        require(msg.sender == lockHolder);
        n = newState;
    }
}
```

An attacker can call `getLock()`, and then never call `releaseLock()`. If they do this, then the contract will be locked forever, and no further changes will be able to be made. If you use mutexes to protect against race conditions, you will need to carefully ensure that there are no ways for a lock to be claimed and never released. (There are other potential dangers when programming with mutexes, such as deadlocks and livelocks. You should consult the large amount of literature already written on mutexes, if you decide to go this route.)

<a name='footnote-race-condition-terminology'></a>

<div style='font-size: 80%; display: inline;'>* Some may object to the use of the term <i>race condition</i> since Ethereum does not currently have true parallelism. However, there is still the fundamental feature of logically distinct processes contending for resources, and the same sorts of pitfalls and potential solutions apply.</div>

## Transaction-Ordering Dependence (TOD) / Front Running

Above were examples of race conditions involving the attacker executing malicious code *within a single transaction*. The following are a different type of race condition inherent to Blockchains: the fact that *the order of transactions themselves* (within a block) is easily subject to manipulation.

Since a transaction is in the mempool for a short while, one can know what actions will occur, before it is included in a block. This can be troublesome for things like decentralized markets, where a transaction to buy some tokens can be seen, and a market order implemented before the other transaction gets included. Protecting against this is difficult, as it would come down to the specific contract itself. For example, in markets, it would be better to implement batch auctions (this also protects against high frequency trading concerns). Another way to use a pre-commit scheme (“I’m going to submit the details later”).

## Timestamp Dependence
Be aware that the timestamp of the block can be manipulated by the miner, and all direct and indirect uses of the timestamp should be considered.

See the [Recommendations](#timestamp-dependence) section for design considerations related to Timestamp Dependence.

## Integer Overflow and Underflow

Consider a simple token transfer:

```sol
mapping (address => uint256) public balanceOf;

// INSECURE
function transfer(address _to, uint256 _value) {
    /* Check if sender has balance */
    require(balanceOf[msg.sender] >= _value);
    /* Add and subtract new balances */
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
}

// SECURE
function transfer(address _to, uint256 _value) {
    /* Check if sender has balance and for overflows */
    require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);

    /* Add and subtract new balances */
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
}
```

If a balance reaches the maximum uint value (2^256) it will circle back to zero. This checks for that condition. This may or may not be relevant, depending on the implementation. Think about whether or not the uint value has an opportunity to approach such a large number. Think about how the uint variable changes state, and who has authority to make such changes. If any user can call functions which update the uint value, it's more vulnerable to attack. If only an admin has access to change the variable's state, you might be safe. If a user can increment by only 1 at a time, you are probably also safe because there is no feasible way to reach this limit.

The same is true for underflow. If a uint is made to be less than zero, it will cause an underflow and get set to its maximum value.

Be careful with the smaller data-types like uint8, uint16, uint24...etc: they can even more easily hit their maximum value.

Be aware there are around [20 cases for overflow and underflow](https://github.com/ethereum/solidity/issues/796#issuecomment-253578925).

### Underflow in Depth: Storage Manipulation
 [Doug Hoyte's submission](https://github.com/Arachnid/uscc/tree/master/submissions-2017/doughoyte) to the 2017 underhanded solidity contest received [an honorable mention](http://u.solidity.cc/). The entry is interesting, because it raises the concerns about how C-like underflow might affect Solidity storage. Here is a simplified version:

```sol
contract UnderflowManipulation {
    address public owner;
    uint256 public manipulateMe = 10;
    function UnderflowManipulation() {
        owner = msg.sender;
    }
    
    uint[] public bonusCodes;
    
    function pushBonusCode(uint code) {
        bonusCodes.push(code);
    }
    
    function popBonusCode()  {
        require(bonusCodes.length >=0);  // this is a tautology
        bonusCodes.length--; // an underflow can be caused here
    }
    
    function modifyBonusCode(uint index, uint update)  { 
        require(index < bonusCodes.length);
        bonusCodes[index] = update; // write to any index less than bonusCodes.length
    }
    
}
```
 
In general, the variable `manipulateMe`'s location cannot be influenced without going through the `keccak256`, which is infeasible. However, since dynamic arrays are stored sequentially, if a malicious actor wanted to change `manipulateMe` all they would need to do is:
 
 * Call `popBonusCode` to underflow (Note: Solidity [lacks a built-in pop method](https://github.com/ethereum/solidity/pull/3743))
 * Compute the storage location of `manipulateMe`
 * Modify and update `manipulateMe`'s value using `modifyBonusCode`

 In practice, this array would be immediately pointed out as fishy, but buried under more complex smart contract architecture, it can arbitrarily allow malicious changes to constant variables.

When considering use of a dynamic array, a container data scructure is a good practice. The Solidity CRUD [part 1](https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a) and [part 2](https://medium.com/@robhitchens/solidity-crud-part-2-ed8d8b4f74ec) articles are good resources.

<a name="dos-with-unexpected-revert"></a>

## DoS with (Unexpected) revert

Consider a simple auction contract:

```sol
// INSECURE
contract Auction {
    address currentLeader;
    uint highestBid;

    function bid() payable {
        require(msg.value > highestBid);

        require(currentLeader.send(highestBid)); // Refund the old leader, if it fails then revert

        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}
```

When it tries to refund the old leader, it reverts if the refund fails. This means that a malicious bidder can become the leader while making sure that any refunds to their address will *always* fail. In this way, they can prevent anyone else from calling the `bid()` function, and stay the leader forever. A recommendation is to set up a [pull payment system](#favor-pull-over-push-for-external-calls) instead, as described earlier.

Another example is when a contract may iterate through an array to pay users (e.g., supporters in a crowdfunding contract). It's common to want to make sure that each payment succeeds. If not, one should revert. The issue is that if one call fails, you are reverting the whole payout system, meaning the loop will never complete. No one gets paid because one address is forcing an error.


```sol
address[] private refundAddresses;
mapping (address => uint) public refunds;

// bad
function refundAll() public {
    for(uint x; x < refundAddresses.length; x++) { // arbitrary length iteration based on how many addresses participated
        require(refundAddresses[x].send(refunds[refundAddresses[x]])) // doubly bad, now a single failure on send will hold up all funds
    }
}
```

Again, the recommended solution is to [favor pull over push payments](#favor-pull-over-push-for-external-calls).

## DoS with Block Gas Limit

You may have noticed another problem with the previous example: by paying out to everyone at once, you risk running into the block gas limit. Each Ethereum block can process a certain maximum amount of computation. If you try to go over that, your transaction will fail.

This can lead to problems even in the absence of an intentional attack. However, it's especially bad if an attacker can manipulate the amount of gas needed. In the case of the previous example, the attacker could add a bunch of addresses, each of which needs to get a very small refund. The gas cost of refunding each of the attacker's addresses could, therefore, end up being more than the gas limit, blocking the refund transaction from happening at all.

This is another reason to [favor pull over push payments](#favor-pull-over-push-for-external-calls).

If you absolutely must loop over an array of unknown size, then you should plan for it to potentially take multiple blocks, and therefore require multiple transactions. You will need to keep track of how far you've gone, and be able to resume from that point, as in the following example:

```sol
struct Payee {
    address addr;
    uint256 value;
}

Payee[] payees;
uint256 nextPayeeIndex;

function payOut() {
    uint256 i = nextPayeeIndex;
    while (i < payees.length && msg.gas > 200000) {
      payees[i].addr.send(payees[i].value);
      i++;
    }
    nextPayeeIndex = i;
}
```

You will need to make sure that nothing bad will happen if other transactions are processed while waiting for the next iteration of the `payOut()` function. So only use this pattern if absolutely necessary.

## Forcibly Sending Ether to a Contract

It is possible to forcibly send Ether to a contract without triggering its fallback function. This is an important consideration when placing important logic in the fallback function or making calculations based on a contract's balance. Take the following example:

```sol
contract Vulnerable {
    function () payable {
        revert();
    }
    
    function somethingBad() {
        require(this.balance > 0);
        // Do something bad
    }
}
```

Contract logic seems to disallow payments to the contract and therefore disallow "something bad" from happening. However, a few methods exist for forcibly sending ether to the contract and therefore making its balance greater than zero. 

The `selfdestruct` contract method allows a user to specify a beneficiary to send any excess ether. `selfdestruct` [does not trigger a contract's fallback function](https://solidity.readthedocs.io/en/develop/security-considerations.html#sending-and-receiving-ether). 

It is also possible to [precompute](https://github.com/Arachnid/uscc/tree/master/submissions-2017/ricmoo) a contract's address and send Ether to that address before deploying the contract.

Contract developers should be aware that Ether can be forcibly sent to a contract and should design contract logic accordingly. Generally, assume that it is not possible to restrict sources of funding to your contract. 

## Deprecated/historical attacks

These are attacks which are no longer possible due to changes in the protocol or improvements to solidity. They are recorded here for posterity and awareness. 

### Call Depth Attack (deprecated)

As of the [EIP 150](https://github.com/ethereum/EIPs/issues/150) hardfork, call depth attacks are no longer relevant<sup><a href='http://ethereum.stackexchange.com/questions/9398/how-does-eip-150-change-the-call-depth-attack'>\*</a></sup> (all gas would be consumed well before reaching the 1024 call depth limit).


#Software Engineering

As we discussed in the [General Philosophy](/general_philosophy/) section, it is not enough to protect yourself against the known attacks. Since the cost of failure on a blockchain can be very high, you must also adapt the way you write software, to account for that risk.

The approach we advocate is to "prepare for failure". It is impossible to know in advance whether your code is secure. However, you can architect your contracts in a way that allows them to fail gracefully, and with minimal damage. This section presents a variety of techniques that will help you prepare for failure.

Note: There's always a risk when you add a new component to your system. A badly designed fail-safe could itself become a vulnerability - as can the interaction between a number of well designed fail-safes. Be thoughtful about each technique you use in your contracts, and consider carefully how they work together to create a robust system.

### Upgrading Broken Contracts

Code will need to be changed if errors are discovered or if improvements need to be made. It is no good to discover a bug, but have no way to deal with it.

Designing an effective upgrade system for smart contracts is an area of active research, and we won't be able to cover all of the complications in this document. However, there are two basic approaches that are most commonly used. The simpler of the two is to have a registry contract that holds the address of the latest version of the contract. A more seamless approach for contract users is to have a contract that forwards calls and data onto the latest version of the contract.

Whatever the technique, it's important to have modularization and good separation between components, so that code changes do not break functionality, orphan data, or require substantial costs to port. In particular, it is usually beneficial to separate complex logic from your data storage, so that you do not have to recreate all of the data in order to change the functionality.

It's also critical to have a secure way for parties to decide to upgrade the code. Depending on your contract, code changes may need to be approved by a single trusted party, a group of members, or a vote of the full set of stakeholders. If this process can take some time, you will want to consider if there are other ways to react more quickly in case of an attack, such as an [emergency stop or circuit-breaker](#circuit-breakers-pause-contract-functionality).

**Example 1: Use a registry contract to store latest version of a contract**

In this example, the calls aren't forwarded, so users should fetch the current address each time before interacting with it.

```sol
contract SomeRegister {
    address backendContract;
    address[] previousBackends;
    address owner;

    function SomeRegister() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner)
        _;
    }

    function changeBackend(address newBackend) public
    onlyOwner()
    returns (bool)
    {
        if(newBackend != backendContract) {
            previousBackends.push(backendContract);
            backendContract = newBackend;
            return true;
        }

        return false;
    }
}
```

There are two main disadvantages to this approach:

1. Users must always look up the current address, and anyone who fails to do so risks using an old version of the contract
2. You will need to think carefully about how to deal with the contract data when you replace the contract

The alternate approach is to have a contract forward calls and data to the latest version of the contract:

**Example 2: [Use a `DELEGATECALL`](http://ethereum.stackexchange.com/questions/2404/upgradeable-contracts) to forward data and calls**

```sol
contract Relay {
    address public currentVersion;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Relay(address initAddr) {
        currentVersion = initAddr;
        owner = msg.sender; // this owner may be another contract with multisig, not a single contract owner
    }

    function changeContract(address newVersion) public
    onlyOwner()
    {
        currentVersion = newVersion;
    }

    function() {
        require(currentVersion.delegatecall(msg.data));
    }
}
```

This approach avoids the previous problems but has problems of its own. You must be extremely careful with how you store data in this contract. If your new contract has a different storage layout than the first, your data may end up corrupted. Additionally, this simple version of the pattern cannot return values from functions, only forward them, which limits its applicability. ([More complex implementations](https://github.com/ownage-ltd/ether-router) attempt to solve this with in-line assembly code and a registry of return sizes.)

Regardless of your approach, it is important to have some way to upgrade your contracts, or they will become unusable when the inevitable bugs are discovered in them.

### Circuit Breakers (Pause contract functionality)

Circuit breakers stop execution if certain conditions are met, and can be useful when new errors are discovered. For example, most actions may be suspended in a contract if a bug is discovered, and the only action now active is a withdrawal. You can either give certain trusted parties the ability to trigger the circuit breaker or else have programmatic rules that automatically trigger the certain breaker when certain conditions are met.

Example:

```sol
bool private stopped = false;
address private owner;

modifier isAdmin() {
    require(msg.sender == owner);
    _;
}

function toggleContractActive() isAdmin public {
    // You can add an additional modifier that restricts stopping a contract to be based on another action, such as a vote of users
    stopped = !stopped;
}

modifier stopInEmergency { if (!stopped) _; }
modifier onlyInEmergency { if (stopped) _; }

function deposit() stopInEmergency public {
    // some code
}

function withdraw() onlyInEmergency public {
    // some code
}
```

### Speed Bumps (Delay contract actions)

Speed bumps slow down actions, so that if malicious actions occur, there is time to recover. For example, [The DAO](https://github.com/slockit/DAO/) required 27 days between a successful request to split the DAO and the ability to do so. This ensured the funds were kept within the contract, increasing the likelihood of recovery. In the case of the DAO, there was no effective action that could be taken during the time given by the speed bump, but in combination with our other techniques, they can be quite effective.

Example:

```sol
struct RequestedWithdrawal {
    uint amount;
    uint time;
}

mapping (address => uint) private balances;
mapping (address => RequestedWithdrawal) private requestedWithdrawals;
uint constant withdrawalWaitPeriod = 28 days; // 4 weeks

function requestWithdrawal() public {
    if (balances[msg.sender] > 0) {
        uint amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0; // for simplicity, we withdraw everything;
        // presumably, the deposit function prevents new deposits when withdrawals are in progress

        requestedWithdrawals[msg.sender] = RequestedWithdrawal({
            amount: amountToWithdraw,
            time: now
        });
    }
}

function withdraw() public {
    if(requestedWithdrawals[msg.sender].amount > 0 && now > requestedWithdrawals[msg.sender].time + withdrawalWaitPeriod) {
        uint amountToWithdraw = requestedWithdrawals[msg.sender].amount;
        requestedWithdrawals[msg.sender].amount = 0;

        require(msg.sender.send(amountToWithdraw));
    }
}
```

### Rate Limiting

Rate limiting halts or requires approval for substantial changes. For example, a depositor may only be allowed to withdraw a certain amount or percentage of total deposits over a certain time period (e.g., max 100 ether over 1 day) - additional withdrawals in that time period may fail or require some sort of special approval. Or the rate limit could be at the contract level, with only a certain amount of tokens issued by the contract over a time period.

[Example](https://gist.github.com/PeterBorah/110c331dca7d23236f80e69c83a9d58c#file-circuitbreaker-sol)

### Contract Rollout

Contracts should have a substantial and prolonged testing period - before substantial money is put at risk.

At minimum, you should:

- Have a full test suite with 100% test coverage (or close to it)
- Deploy on your own testnet
- Deploy on the public testnet with substantial testing and bug bounties
- Exhaustive testing should allow various players to interact with the contract at volume
- Deploy on the mainnet in beta, with limits to the amount at risk

##### Automatic Deprecation

During testing, you can force an automatic deprecation by preventing any actions, after a certain time period. For example, an alpha contract may work for several weeks and then automatically shut down all actions, except for the final withdrawal.

```sol
modifier isActive() {
    require(block.number <= SOME_BLOCK_NUMBER);
    _;
}

function deposit() public isActive {
    // some code
}

function withdraw() public {
    // some code
}

```
##### Restrict amount of Ether per user/contract

In the early stages, you can restrict the amount of Ether for any user (or for the entire contract) - reducing the risk.

### Bug Bounty Programs

Some tips for running bounty programs:

- Decide which currency bounties will be distributed in (BTC and/or ETH)
- Decide on an estimated total budget for bounty rewards
- From the budget, determine three tiers of rewards:
  - smallest reward you are willing to give out
  - highest reward that's usually awardable
  - an extra range to be awarded in case of very severe vulnerabilities
- Determine who the bounty judges are (3 may be ideal typically)
- Lead developer should probably be one of the bounty judges
- When a bug report is received, the lead developer, with advice from judges, should evaluate the severity of the bug
- Work at this stage should be in a private repo, and the issue filed on Github
- If it's a bug that should be fixed, in the private repo, a developer should write a test case, which should fail and thus confirm the bug
- Developer should implement the fix and ensure the test now passes; writing additional tests as needed
- Show the bounty hunter the fix; merge the fix back to the public repo is one way
- Determine if bounty hunter has any other feedback about the fix
- Bounty judges determine the size of the reward, based on their evaluation of both the *likelihood* and *impact* of the bug.
- Keep bounty participants informed throughout the process, and then strive to avoid delays in sending them their reward

For an example of the three tiers of rewards, see [Ethereum's Bounty Program](https://bounty.ethereum.org):

> The value of rewards paid out will vary depending on severity of impact. Rewards for minor 'harmless' bugs start at 0.05 BTC. Major bugs, for example leading to consensus issues, will be rewarded up to 5 BTC. Much higher rewards are possible (up to 25 BTC) in case of very severe vulnerabilities.


#Documentation and Procedures

When launching a contract that will have substantial funds or is required to be mission critical, it is important to include proper documentation. Some documentation related to security includes:

## Specifications and Rollout Plans

- Specs, diagrams, state machines, models, and other documentation that helps auditors, reviewers, and the community understand what the system is intended to do.
- Many bugs can be found just from the specifications, and they are the least costly to fix.
- Rollout plans that include details listed [here](https://github.com/ConsenSys/smart-contract-best-practices#contract-rollout), and target dates.

## Status

- Where current code is deployed
- Compiler version, flags used, and steps for verifying the deployed bytecode matches the source code
- Compiler versions and flags that will be used for the different phases of rollout.
- Current status of deployed code (including outstanding issues, performance stats, etc.)

## Known Issues

- Key risks with contract
  - e.g., You can lose all your money, hacker can vote for certain outcomes
- All known bugs/limitations
- Potential attacks and mitigants
- Potential conflicts of interest (e.g., will be using yourself, like Slock.it did with the DAO)

## History

- Testing (including usage stats, discovered bugs, length of testing)
- People who have reviewed code (and their key feedback)

## Procedures

- Action plan in case a bug is discovered (e.g., emergency options, public notification process, etc.)
- Wind down process if something goes wrong (e.g., funders will get percentage of your balance before attack, from remaining funds)
- Responsible disclosure policy (e.g., where to report bugs found, the rules of any bug bounty program)
- Recourse in case of failure (e.g., insurance, penalty fund, no recourse)

## Contact Information

- Who to contact with issues
- Names of programmers and/or other important parties
- Chat room where questions can be asked


#Security Tools

### Static Analysis

- [Manticore](https://github.com/trailofbits/manticore) - Dynamic binary analysis tool with [EVM support](https://asciinema.org/a/haJU2cl0R0Q3jB9wd733LVosL)
- [Mythril](https://github.com/b-mueller/mythril/) - Reversing and bug hunting framework for the Ethereum blockchain
- [Oyente](https://github.com/melonproject/oyente) - Analyze Ethereum code to find common vulnerabilities, based on this [paper](http://www.comp.nus.edu.sg/~loiluu/papers/oyente.pdf).
- [Solgraph](https://github.com/raineorshine/solgraph) - Generates a DOT graph that visualizes function control flow of a Solidity contract and highlights potential security vulnerabilities.
- [SmartCheck](https://tool.smartdec.net) - Static analysis of Solidity source code for security vulnerabilities and best practices.

### Test Coverage

- [solidity-coverage](https://github.com/sc-forks/solidity-coverage) - Code coverage for Solidity testing.


### Linters

Linters improve code quality by enforcing rules for style and composition, making code easier to read and review.

- [Solcheck](https://github.com/federicobond/solcheck) - A linter for Solidity code written in JS and heavily inspired by eslint.
- [Solint](https://github.com/weifund/solint) - Solidity linting that helps you enforce consistent conventions and avoid errors in your Solidity smart-contracts.
- [Solium](https://github.com/duaraghav8/Solium) - Yet another Solidity linting.
- [Solhint](https://github.com/protofire/solhint) - A linter for Solidity that provides both Security and Style Guide validations.


#Security Notifications

This is a list of resources that will often highlight discovered exploits in Ethereum or Solidity. The official source of security notifications is the Ethereum Blog, but in many cases, vulnerabilities will be disclosed and discussed earlier in other locations.

- [Ethereum Blog](https://blog.ethereum.org/): The official Ethereum blog
  - [Ethereum Blog - Security only](https://blog.ethereum.org/category/security/): All blog posts that are tagged *Security*
- [Ethereum Gitter](https://gitter.im/orgs/ethereum/rooms) chat rooms
  - [Solidity](https://gitter.im/ethereum/solidity)
  - [Go-Ethereum](https://gitter.im/ethereum/go-ethereum)
  - [CPP-Ethereum](https://gitter.im/ethereum/cpp-ethereum)
  - [Research](https://gitter.im/ethereum/research)
- [Reddit](https://www.reddit.com/r/ethereum)
- [Network Stats](https://ethstats.net/)

It's highly recommended that you *regularly* read all these sources, as exploits they note may impact your contracts.

Additionally, here is a list of Ethereum core developers who may write about security, and see the [bibliography](https://github.com/ConsenSys/smart-contract-best-practices#smart-contract-security-bibliography) for more from the community.

- **Vitalik Buterin**: [Twitter](https://twitter.com/vitalikbuterin), [Github](https://github.com/vbuterin), [Reddit](https://www.reddit.com/user/vbuterin), [Ethereum Blog](https://blog.ethereum.org/author/vitalik-buterin/)
- **Dr. Christian Reitwiessner**: [Twitter](https://twitter.com/ethchris), [Github](https://github.com/chriseth), [Ethereum Blog](https://blog.ethereum.org/author/christian_r/)
- **Dr. Gavin Wood**: [Twitter](https://twitter.com/gavofyork), [Blog](http://gavwood.com/), [Github](https://github.com/gavofyork)
- **Vlad Zamfir**: [Twitter](https://twitter.com/vladzamfir), [Github](https://github.com/vladzamfir), [Ethereum Blog](https://blog.ethereum.org/author/vlad/)

Beyond following core developers, it is critical to participate in the wider blockchain-related security community - as security disclosures or observations will come through a variety of parties.


#Tokens


# Token Implementation Best Practice

Implementing Tokens should comply with other best practices, but also have some unique considerations.

## Comply with the latest standard

Generally speaking, smart contracts of tokens should follow an accepted and stable standard. 

Examples of currently accepted standards are:

* [EIP20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)
* [EIP721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) (non-fungible token)

## Be aware of front running attacks on EIP-20

The EIP-20 token's `approve()` function creates the potential for an approved spender to spend more than the intended amount. A [front running attack](#transaction-ordering-dependence-tod-front-running) can be used, enabling an approved spender to call `transferFrom()` both before and after the call to `approve()` is processed. More details are available on the [EIP](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve), and in [this document](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit).


## Prevent transferring tokens to the 0x0 address

At the time of writing, the "zero" address ([0x0000000000000000000000000000000000000000](https://etherscan.io/address/0x0000000000000000000000000000000000000000)) holds tokens with a value of more than 80$ million.


## Prevent transferring tokens to the contract address

Consider also preventing the transfer of tokens to the same address of the smart contract. 

An example of the potential for loss by leaving this open is the [EOS token smart contract](https://etherscan.io/address/0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0) where more than 90,000 tokens are stuck at the contract address. 

### Example

An example of implementing both the above recommendations would be to create the following modifier; validating that the "to" address is neither 0x0 nor the smart contract's own address:

```sol
    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }
```

The modifier should then be applied to the "transfer" and "transferFrom" methods:

```sol 
    function transfer(address _to, uint _value)
        validDestination(_to)
        returns (bool) 
    {
        (... your logic ...)
    }

    function transferFrom(address _from, address _to, uint _value)
        validDestination(_to)
        returns (bool) 
    {
        (... your logic ...)
    }
```

