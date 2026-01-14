//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {PriceConverter} from "../src/PriceConverterLibrary.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;
    address[] public funders;
    mapping(address funders => uint256 amountFunded) public addressToAmountFunded;

    address public owner;
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "Didn't send enough ETH.");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not the owner");
        _;
    }
}