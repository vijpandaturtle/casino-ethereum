pragma solidity 0.4.21;

contract Casino {
  address public owner;
  uint256 public minimumBet;
  uint256 public totalBet;
  uint256 public numberofBets;
  uint256 public maxAmountofBets = 100;
  //Keeps track of all the players and their addresses. This will be useful in checking if the player has already played the game or not.
  address[] public players;

  //Storing credentials of each player
  struct Player {
    uint256 amountBet;
    uint256 numberSelected;
  }

  //The address of the player and the user info. Here address will be used for indexing in the playerInfo array.
  mapping(address=>Player) public playerInfo;

  //Fallback function in case someone sends ether, so that it dosen't get lost
  function () public payable {}

  function Casino(uint256 _minimumBet) public {
    owner = msg.sender;
    if(_minimumBet != 0) minimumBet = _minimumBet;
  }

  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
  }

  function checkPlayerExists(address player) public constant
  returns (bool) {
     for(uint256 i = 0; i <= players.length; i++) {
       if(players[i] == player) return true;
     }
     return false;
  }

  //To bet for a number between 1 and 10 both inclusive
  function bet(uint256 numberSelected) public payable {
      require(!checkPlayerExists(msg.sender));
      require(numberSelected >= 1 && numberSelected <= 10);
      require(msg.value >= minimumBet);

      playerInfo[msg.sender].amountBet = msg.value;
      playerInfo[msg.sender].numberSelected = numberSelected;
      numberofBets ++;
      players.push(msg.sender);
      totalBet += msg.value;

      if(numberofBets >= maxAmountofBets) generateNumberWinner();
  }

  //Randomly generates a number between 1 and 10 which will be the winner
  function generateNumberWinner() public {
     uint256 numberGenerated = block.number % 10 + 1;
     distributePrizes(numberGenerated);
  }

  //Distributes prize i.e ether to the winner depending upon the total bets
  function distributePrizes(uint256 winner) public {
      address[100] memory winners; //Creating a temporary array in memory with a fixed size
      uint256 count = 0;

      //Populating the list of winners and clearing out the players address & credentials for a new game run
      for(uint256 i = 0; i < players.length; i++) {
        address playerAddress = players[i];
        if(playerInfo[playerAddress].numberSelected == winner){
         winners[count] = playerAddress;
         count++;
      }
      delete playerInfo[playerAddress]; // Delete all the players
      }

      players.length = 0; //Delete the players array

      uint256 winnerEtherAmount = totalBet/winners.length; //Alloting prizes to each player according to the their total betting amount

      for(uint256 j = 0; j < count; j++) {
        if(winners[j] != address(0)) //Checking to make sure the address isnt empty
        winners[j].transfer(winnerEtherAmount);
      }
  }

  function resetData() {
    players.length = 0; //Delete all the players in the array
    totalBet = 0;
    numberofBets = 0;
  }
}
