// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract Escrow {
    // Variables
    enum State {
        NOT_INITIATED,
        AWAITING_PAYMENT, 
        AWAITING_DELIVERY,
        COMPLETE
    }
    
    // To know whether current Escrow contract is initiated or not!
    State public currState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint public price;

    address public buyer;
    address payable public seller;

    // Modifiers
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function!");
        _;
    }

    modifier escrowNotStarted() {
        require(currState == State.NOT_INITIATED);
        _;
    }

    // Functions 
    constructor(address _buyer, address payable _seller, uint _price) public {
       buyer = _buyer;
       seller = _seller;

       // As we only want this to be dealt in ether!
       price = _price * (1 ether); 
    }

    function initContract() escrowNotStarted public {
       if (msg.sender == buyer) {
           isBuyerIn = true;
       }
       if (msg.sender == seller) {
           isSellerIn = true;
       }
       if (isBuyerIn && isSellerIn) {
           currState = State.AWAITING_PAYMENT;
       }
    }

    function deposit() onlyBuyer public payable {
       require(currState == State.AWAITING_PAYMENT, "Already Paid!");
       require(msg.value == price, "Wrong deposit Amount!"); // Buyer must pay the seller wanted price!
       currState = State.AWAITING_DELIVERY;
    }
    
    // This func() transfers the funds to the seller from buyer!
    function confirmDelivery() onlyBuyer public payable {
       require(currState == State.AWAITING_DELIVERY, "Cannot confirm the delivery!");
       payable(seller).transfer(price);
       currState = State.COMPLETE;
    }

    function withdraw() onlyBuyer payable public {
       require(currState == State.AWAITING_DELIVERY, "Cannot withdraw at this stage!");
       payable(msg.sender).transfer(price);
       currState = State.COMPLETE;
    }
}