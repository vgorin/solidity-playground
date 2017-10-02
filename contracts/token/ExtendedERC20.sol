pragma solidity 0.4.15;

import './ERC20.sol';

// Extended ERC20 standard, better supporting wallets
// https://theethereum.wiki/w/index.php/ERC20_Token_Standard
contract ExtendedERC20 is ERC20 {
	string public symbol;
	string public name;
	uint8 public decimals;
}
