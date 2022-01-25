// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// Time in solidity is purely based on epoch(seconds)

contract MyGame {
    uint public playerCount = 0;
    mapping (address => Player) public players;

    enum Level {Beginner, Intermediate, Advanced}

    struct Player {
        address playerAddress;
        Level playerLevel;
        string firstName;
        string lastName;
        uint createdTime;
    }

    function addPlayer(string memory firstName, string memory lastName) public {
        players[msg.sender] = Player(msg.sender, Level.Beginner, firstName, lastName, block.timestamp);
        playerCount += 1;
    }

    function getPlayerLevel(address playerAddress) public view returns(Level) {
        Player storage player_var = players[playerAddress];
        return player_var.playerLevel;
    }

    function changePlayerLevel(address playerAddress) public {
        Player storage player_var = players[playerAddress];
        if(block.timestamp >= player_var.createdTime + 20) {
            player_var.playerLevel = Level.Intermediate;
        }
    }
}