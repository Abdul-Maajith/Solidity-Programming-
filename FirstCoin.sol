// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// When a particular address has enough coin, from that particular address, we can send funds to another address!
contract Coin {
    address public minter;
    mapping (address => uint) public balances;
    
    // Notes down, every transaction in a log, whenever it is triggered! - by emit!
    // Events notify the applications about the change made to the contracts and which stores the arguments passed in the transaction logs when emitted. 
    // we can trigger this event, whenever the user sends coin to someone else & how much we sent!..
    event Sent(address from, address to, uint amount);

    // Runs only once - to find the ownerAddress of the coin..
    constructor() public {
        minter = msg.sender;
    }

    // Modifier - just splits up the code into smaller pieces! - we can use this to other contracts to import these fuctionalities!
    modifier onlyMinter {
        require(msg.sender == minter, "Only Minter can call this function!"); //Only owner address can mint the coin!
        _;
    }
    
    modifier amountGreaterThan(uint amount) {
        require(amount < 1e60);
        _;
    }

    modifier balanceGreaterThanAmount(uint amount) {
        require(amount <= balances[msg.sender], "Insufficient Balances!");
        _;
    }
    
    // require() - just like a If-else condition statements..
    // Minting a coin - creating a coin and store it in a wallet!
    function mint(address receiver, uint amount) public onlyMinter amountGreaterThan(amount) {
       balances[receiver] += amount;
    }

    // sending a coin...
    function send(address receiver, uint amount) public balanceGreaterThanAmount(amount) {
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}