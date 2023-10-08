// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  mapping (address => uint) public balances;
  uint public constant threshold = 1 ether;

  uint public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;


  event Stake(address,uint);

  modifier outOfDate{
    require(block.timestamp>=deadline,"still on going");
    _;
  }

  modifier onDate{
    require(block.timestamp<deadline,"Not on Date");
    _;
  }

  modifier notCompleted{
    require(!exampleExternalContract.completed(),"Already completed");
    _;
  }

  function stake() public payable notCompleted onDate{
    require(msg.value>0,"Not enough ethers");
    balances[msg.sender] = msg.value+balances[msg.sender];
    emit Stake(msg.sender,msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public notCompleted outOfDate{
    if (address(this).balance<threshold && !exampleExternalContract.completed()) {
      openForWithdraw=true;
    }else {
      exampleExternalContract.complete{value: address(this).balance}();
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public{
    require(openForWithdraw,"Not open for withdraw");
    payable(msg.sender).transfer(balances[msg.sender]);
    balances[msg.sender] = 0;
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint) {
    if(block.timestamp >= deadline){
      return 0;
    }
    return deadline-block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive()external payable{
    stake();
  }
}
