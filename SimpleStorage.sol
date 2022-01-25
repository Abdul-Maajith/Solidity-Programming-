// An Application to store information in the blockchain!

// When we want to deploy this - we need to give some gas in wei!

// Defining the version of solidity, we are gonna use! 
// ^0.6.0 - It can include all the version 0f 0.6.(1, 2, 3, 4...)
// Must end every statment with semicolon
pragma solidity ^0.6.0;

// Defining a contract - Just like the class(blueprint of an object).
// It can have objects which shares different characteristics with common behaviour

contract SimpleStorage {

   // Declaring a variable - we also need to declare the datatype
   // unsigned(+ve only) and signed(both +ve and -ve) with the size of 256bit.

   uint256 public favNumber;
   bool favouriteBool = false;
   string favString = "String";
   int256 favInt = -5;
   address favAddress = 0x0CF90f65D56ad65dDC97AE5985C30aD80bB25Dc7;

   // Creating a function => 
   // Visibility Quantifiers -> default - "internal"
   // "External" - These are meant to be called by others, cannot be called for internal line we did in recursion.
   // "internal" - These can only be used internally or by derived contracts.
   // "public" - It can be used both internally and externally of a contract!
   // "private" - It can only be used internally and not even by derived contracts.
   
   function store(uint256 _favouriteNumber) public {
       favNumber = _favouriteNumber;
   }
   
   function retrieve() public view returns(uint256) {
       return favNumber;
   }
}
