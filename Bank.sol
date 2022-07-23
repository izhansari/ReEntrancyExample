// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

    /*
    a simple contract that stores money for people. 
    They can check their balance. 
    For sake of testing, you can...
     -check how much money is in the bank 
     -see how much money other accounts have
    */

contract Bank {
    bool locked = false;
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

   modifier reEntrancyGuard {
       //this part will run before the function
       require(!locked, "ReEntrancy Guard");
       locked = true;
       _;
       //this part will run after the function
       locked = false;
   }

    /*
    To protect against reentry...
     - add reEntrancyGuard modifier to stop attacks.
     -or move 'balances[msg.sender] = 0' statement above the line that sends the money.
    */
    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function: check balance of this contract
    function moneyInBank() public view returns (uint) {
        return address(this).balance;
    }

    // Helper function: check balance of current account
    function getMyBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}