// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// Payable - this keyword is used to send some coins.
contract simpleAuction {
    // Parameters of the SimpleAuction
    address payable public beneficiary;
    uint public auctionEndTime;

    // Current state of the auctionEndTime
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public pendingReturns;
    bool ended = false;

    // To keep track of the highestBidder, the highest amount he is betting! and to find the actual winner of that auction!
    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    // Runs only once - to get the beneficiary and auction end time at the deployment of this contract!
    constructor(uint _biddingTime, address payable _beneficiary) public {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        if (block.timestamp > auctionEndTime) {
            revert("The auction has already ended!");
        }

        if (msg.value <= highestBid) {
            revert("There is already higher (or) equal bid!");
        }

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit  HighestBidIncrease(msg.sender, msg.value);
    }

    function withdraw() public returns(bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        if (block.timestamp < auctionEndTime) {
            revert("The auction has not ended yet!");
        }

        if (ended) {
            revert("The Function auctionEnded has already been called!");
        }

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}