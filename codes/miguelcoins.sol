// Code based on https://github.com/hagenderouen/mini-chain/blob/master/hadcoins_ico.sol 
// and https://github.com/joueyama/blockchain/blob/main/jocoin.sol

// Version of compiler
pragma solidity ^0.5.0;

contract miguelcoin_ico {

    // Imprimindo o número máximo de miguelcoins à venda
    uint public max_miguelcoins = 1000000000000;

    // Imprimindo a taxa de conversão de USD para miguelcoins
    uint public usd_to_miguelcoins = 13671894;

    // Imprimindo o número total de miguelcoins que foram comprados por investidores
    uint public total_miguelcoins_bought = 0;

    // Mapeamento do endereço do investidor para seu patrimônio em miguelcoins para USD
    mapping(address => uint) equity_miguelcoins;
    mapping(address => uint) equity_usd;

    // Verificando se um investidor pode comprar miguelcoins
    modifier can_buy_miguelcoins(uint usd_invested) {
        require (usd_invested * usd_to_miguelcoins + total_miguelcoins_bought <= max_miguelcoins);
        _;
    }

    // Verificando se um investidor pode vender miguelcoins
    modifier can_sell_miguelcoins(uint miguelcoins_sold) {
        require (equity_miguelcoins[msg.sender] >= miguelcoins_sold, "no money");
        _;
    }

    // Obtendo o patrimônio em miguelcoins de um investidor
    function equity_in_miguelcoins(address investor) external view returns (uint) {
        return equity_miguelcoins[investor];
    }

    // Obtendo o patrimônio em dólares de um investidor
    function equity_in_usd(address investor) external view returns (uint) {
        return equity_usd[investor];
    }

    // Comprando miguelcoins
    function buy_miguelcoins(uint usd_invested) external
    can_buy_miguelcoins(usd_invested) {
        uint miguelcoins_bought = usd_invested * usd_to_miguelcoins;
        equity_miguelcoins[msg.sender] += miguelcoins_bought;
        equity_usd[msg.sender] = equity_miguelcoins[msg.sender] / 13671894;
        total_miguelcoins_bought += miguelcoins_bought;
    }

    // Vendendo miguelcoins
    function sell_miguelcoins(uint miguelcoins_sold) external 
    can_sell_miguelcoins(miguelcoins_sold) {
        equity_miguelcoins[msg.sender] -= miguelcoins_sold;
        equity_usd[msg.sender] = equity_miguelcoins[msg.sender] / 13671894;
        total_miguelcoins_bought -= miguelcoins_sold;
    }

    // Transferindo miguelcoins
    function transfer_miguelcoins(uint miguelcoins, address receiver) external
    can_sell_miguelcoins(miguelcoins) {
        equity_miguelcoins[msg.sender] -= miguelcoins;
        equity_miguelcoins[receiver] += miguelcoins;
    }
}
