// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// Time in solidity is purely based on epoch(seconds)

contract MyGame {
    uint public playerCount = 0;
    uint public pot = 0;
    address public dealer;

    Player[] public playersInGame; //to loop through the players! as we can't loop in mappings..

    mapping (address => Player) public players;
    enum Level {Beginner, Intermediate, Advanced}

    struct Player {
        address playerAddress;
        Level playerLevel;
        string firstName;
        string lastName;
        uint createdTime;
    }
     
    constructor() public {
        dealer = msg.sender;
    }

    function addPlayer(string memory firstName, string memory lastName) private {
        Player memory newPlayer = Player(msg.sender, Level.Beginner, firstName, lastName, block.timestamp);
        players[msg.sender] = newPlayer;
        playersInGame.push(newPlayer);
    }

    function getPlayerLevel(address playerAddress) private view returns(Level) {
        Player storage player_var = players[playerAddress];
        return player_var.playerLevel;
    }

    function changePlayerLevel(address playerAddress) private {
        Player storage player_var = players[playerAddress];
        if(block.timestamp >= player_var.createdTime + 20) {
            player_var.playerLevel = Level.Intermediate;
        }
    }
    
    // Players need to spend 25 ether to join the game, and the dealer ends the game and payout whoever the winner is!
    function joinGame(string memory firstName, string memory lastName) payable public {
        require(msg.value == 25 ether, "The joining fee is 5 ether!!");
        if (payable(dealer).send(msg.value)) { // dealer gets all the initial amount, funded by the players - 25eth.
            addPlayer(firstName, lastName);
            playerCount += 1;
            pot += 25;
        }
    }

    function payOutWinners(address loserAddress) payable public {
        require(msg.sender == dealer, "Only the dealers can payout the winners!");
        require(msg.value == pot * (1 ether)); // Amount required for the dealer to payOut the winners!
        uint payoutPerWinner = msg.value / (playerCount - 1);
        for (uint i=0; i < playersInGame.length; i++) {
            address currentPlayerAddress = playersInGame[i].playerAddress;

            // Check for the losers - Only paysout the coin for the winner!
            if (currentPlayerAddress != loserAddress) {
                payable(currentPlayerAddress).transfer(payoutPerWinner);
            }
        }
    }
}