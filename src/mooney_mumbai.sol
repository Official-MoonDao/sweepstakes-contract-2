
pragma solidity ^0.8.19;  

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITickets} from "./ITickets.sol";

contract MumbaiMooney is ERC20, Ownable, ITickets {
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    {

    }

    function print(address _account, uint256 _amount)
        external
        override
        onlyOwner
    {
        return _mint(_account, _amount);
    }

    function redeem(address _account, uint256 _amount)
        external
        override
        onlyOwner
    {
        return _burn(_account, _amount);
    }
}