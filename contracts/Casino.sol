pragma solidity 0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Casino is usingOraclize {

  address owner;
  uint256 public minimumBet = 100 finney;
  uint256 public totalBet;
  uint256 public numberOfBets;
  uint256 public maxAmountOfBets = 10;
  address[] public players;

  struct Player {
    uint256 amountBet;
    uint256 numberSelected;
  }

  //playerInfo[address].amountBet;
  mapping(address => Player) public playerInfo;

  function () public payable {}

  function Casino(uint256 _minimumBet) public {
    owner = msg.sender;
    if(_minimumBet != 0) minimumBet = _minimumBet;
  }

  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
  }

  function checkPlayerExists(address player) public constant returns(bool) {
    for(uint256 i=0; i < players.length; i++) {
      if(players[i] == player) return true;
    }
    return false;
  }

  //to bet for a number between 1 and 10
  function bet(uint256 numberSelected) public payable {
    require(!checkPlayerExists(msg.sender));
    require(numberSelected >= 1 && numberSelected <= 10);
    require(msg.value >= minimumBet);

    playerInfo[msg.sender].amountBet = msg.value;
    playerInfo[msg.sender].numberSelected = numberSelected;
    numberOfBets++;
    players.push(msg.sender);
    totalBet += msg.value;
  }

  //generate number between 1 and 10 that will be winner
  function generateNumberWinner() public {
    uint256 numberGenerated = block.number % 10 + 1;
    distributePrizes(numberGenerated);
  }

  function distributePrizes(uint256 numberWinner) public {
    address[100] memory winners;
    uint256 count = 0;

    for(uint256 i = 0; i < players.length; i++) {
      address playerAddress = players[i];
      if(playerInfo[playerAddress].numberSelected == numberWinner) {
        winners[count] = playerAddress;
        count++;
      }
      delete playerInfo[playerAddress];
    }

    players.length = 0;

    uint256 winnerEtherAmount = totalBet / winners.length;

    for(uint256 j = 0; j < count; j++){
      if(winners[j] != address(0))
        winners[j].transfer(winnerEtherAmount);
    }
  }
}
