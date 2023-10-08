pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  uint256 public constant tokensPerEth = 100;


  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable{
    require(msg.value>0,"Not Ethers send");
    uint amount = msg.value*tokensPerEth;
    yourToken.transfer(msg.sender,amount);
    emit BuyTokens(msg.sender,msg.value,amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }
  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint _amount) public {
    yourToken.transferFrom(msg.sender,address(this),_amount);
    payable(msg.sender).transfer(_amount/tokensPerEth);
    emit SellTokens(msg.sender,_amount,_amount/tokensPerEth);
  }
}
