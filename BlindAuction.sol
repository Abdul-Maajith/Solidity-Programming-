// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract BlindAuction {
    
   // Variables =>
   struct Bid {
      bytes32 blindedBid;
      uint deposit;
   }

   address payable public beneficiary;
   uint public biddingEnd;
   uint public revealEnd;
   bool public ended;
   
   mapping(address => Bid[]) public bids;

   address public highestBidder;
   uint public highestBid;

   mapping(address => uint) public pendingReturns;

   // Events =>
   event AuctionEnded(address winner, uint highestBid);

   // Modifiers => 
   modifier onlyBefore(uint _time) {
      require(block.timestamp < _time);
      _;
   }

   modifier onlyAfter(uint _time) {
      require(block.timestamp > _time);
      _;
   }
   
   // Functions => 
   constructor(
      uint _biddingTime,
      uint _revealTime, 
      address payable _beneficiary
   )  public 
   {
      beneficiary = _beneficiary;
      biddingEnd = block.timestamp + _biddingTime;
      revealEnd = biddingEnd + _revealTime;
   }
   
   // Encrypting the bidding value as hash(Bytes 32)! 
   function generateBlindedBidBytes32(uint value, bool fake) public pure returns (bytes32) {
      return keccak256(abi.encodePacked(value, fake));
   }
   
   function bid(bytes32 _blindedBid) public payable onlyBefore(biddingEnd) {
      bids[msg.sender].push(Bid({
         blindedBid: _blindedBid,
         deposit: msg.value
      }));
   }
   
   function reveal(
      uint[] memory _values,
      bool[] memory _fake
   ) 
     public 
     onlyAfter(biddingEnd) 
     onlyBefore(revealEnd) 
   {
      uint length = bids[msg.sender].length;
      require(_values.length == length);
      require(_fake.length == length);

      for (uint i=0; i<length; i++) {
         Bid storage bidToCheck = bids[msg.sender][i];
         (uint value, bool fake) = (_values[i], _fake[i]);
         if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake))) {
            continue; // Skips rest of the code, move on to next iteration!
         }
         if(!fake && bidToCheck.deposit >= value) {
            if(!placeBid(msg.sender, value)) {
               payable(msg.sender).transfer(bidToCheck.deposit * (1 ether));
            }
         }
         bidToCheck.blindedBid = bytes32(0);
      }
   }

   function withdraw() public {
      uint amount = pendingReturns[msg.sender];

      // If there is any pending, pay it out to the owner! and make pendingReturns to zero!
      if (amount > 0) {
         pendingReturns[msg.sender] = 0; 
         payable(msg.sender).transfer(amount * (1 ether));
      }
   }

   function auctionEnd() public payable onlyAfter(revealEnd) {
      require(!ended);
      emit AuctionEnded(highestBidder, highestBid);
      ended = true;
      beneficiary.transfer(highestBid);
   }
   
   // this func() only triggered within the reveal function!
   function placeBid(address bidder, uint value) internal returns (bool success) { 
      // We only accept bids, which is higher than the old highest bids!
      if (value <= highestBid) {
         return false;
      }

      if (highestBidder != address(0)) {
         pendingReturns[highestBidder] += highestBid;
      }

      highestBidder = bidder;
      highestBid = value;
      return true;
   }

}