//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "../src/PriceConverterLibrary.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256 ) public addressToAmountFunded;
    uint256 public MINIMUM_USD = 5e18;
    address[] public funders;
    address public i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH.");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }


    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Sender is not the owner");
        _;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}