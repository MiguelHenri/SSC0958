// Code based on https://github.com/hagenderouen/mini-chain/blob/master/hadcoins_ico.sol 
// and https://github.com/joueyama/blockchain/blob/main/jocoin.sol

// Version of compiler
pragma solidity ^0.5.0;

contract miguelcoin_ico {

    // max miguelcoins for sale
    uint public max_miguelcoins = 1000000000000;

    // usd to miguelcoins conversion rate
    uint public usd_to_miguelcoins = 13671894;

    // the total number of miguelcoins that have been bought by investors
    uint public total_miguelcoins_bought = 0;

    // mapping from the investor address to its equity in miguelcoins / USD
    mapping(address => uint) equity_miguelcoins;
    mapping(address => uint) equity_usd;

    // checking if an investor can buy miguelcoins
    modifier can_buy_miguelcoins(uint usd_invested) {
        require (usd_invested * usd_to_miguelcoins + total_miguelcoins_bought <= max_miguelcoins);
        _;
    }

    // checking if an investor can sell miguelcoins
    modifier can_sell_miguelcoins(uint miguelcoins_sold) {
        require (equity_miguelcoins[msg.sender] >= miguelcoins_sold, "no money");
        _;
    }

    // getting the equity in miguelcoins of an investor
    function equity_in_miguelcoins(address investor) external view returns (uint) {
        return equity_miguelcoins[investor];
    }

    // getting the equity in USD of an investor
    function equity_in_usd(address investor) external view returns (uint) {
        return equity_usd[investor];
    }

    // buying miguelcoins
    function buy_miguelcoins(uint usd_invested) external
    can_buy_miguelcoins(usd_invested) {
        uint miguelcoins_bought = usd_invested * usd_to_miguelcoins;
        equity_miguelcoins[msg.sender] += miguelcoins_bought;
        equity_usd[msg.sender] = equity_miguelcoins[msg.sender] / 13671894;
        total_miguelcoins_bought += miguelcoins_bought;
    }

    // selling miguelcoins
    function sell_miguelcoins(uint miguelcoins_sold) external 
    can_sell_miguelcoins(miguelcoins_sold) {
        equity_miguelcoins[msg.sender] -= miguelcoins_sold;
        equity_usd[msg.sender] = equity_miguelcoins[msg.sender] / 13671894;
        total_miguelcoins_bought -= miguelcoins_sold;
    }

    // transferring miguelcoins
    function transfer_miguelcoins(uint miguelcoins, address receiver) external
    can_sell_miguelcoins(miguelcoins) {
        equity_miguelcoins[msg.sender] -= miguelcoins;
        equity_miguelcoins[receiver] += miguelcoins;
    }
}
