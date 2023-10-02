// Code based on jocoins ICO https://github.com/hagenderouen/mini-chain/blob/master/hadcoins_ico.sol
// SPDX-License-Identifier: GPL-3.0

// Version of compiler
pragma solidity >=0.7.0 <0.9.0;

contract jocoinErc20 {

    // Mapeamento do endereço do investidor para seu patrimônio em jocoins e em USD
    mapping(address => uint) private equity_jocoins;
    mapping(address => uint) private equity_usd;

    // Número máximo de jocoins à venda
    uint256 private _totalSupply;

    // Padrão Erc20
    string private _name;
    string private _symbol;

    // Construtor, seta variáveis
    constructor() {
        _name = "Jocoin";
        _symbol = "JOC";
        _totalSupply = 1e6;
    }

    // Taxa de conversão de USD para jocoins
    uint private usd_to_jocoins = 1000;

    // Total de jocoins que foram comprados por investidores
    uint private total_jocoins_bought = 0;

    // Erc20 Name
    function name() public view returns(string memory) {
        return _name;
    }

    // Erc20 Symbol
    function symbol() public view returns(string memory) {
        return _symbol;
    }

    // Erc20 TotalSupply
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    // Erc20 BalanceOf

    // Erc20 Transfer

    // Verificando se um investidor pode comprar jocoins
    modifier can_buy_jocoins(uint usd_invested) {
        require (usd_invested * usd_to_jocoins + total_jocoins_bought <= _totalSupply, "jocoins indisponiveis");
        _;
    }

    // Verificando se um investidor pode vender jocoins
    modifier can_sell_jocoins(address investor, uint jocoins_sold) {
        // Retirada de, no máximo, 10% do saldo
        require (jocoins_sold <= equity_jocoins[investor]*9/10, "valor maior que 90% do saldo");
        // Venda apenas após as 22h
        uint _time = block.timestamp - 3*60*60; // mudando para BRT
        _time = _time % (24*60*60); // horario em segundos
        require (_time <= 14*60*60, "a venda so eh permitida ate as 14h");
        _;
    }

    // Comprando jocoins
    function buy_jocoins(address investor, uint usd_invested) external
    can_buy_jocoins(usd_invested) {
        // Convertendo de USD para Jocoin
        uint jocoins_bought = usd_invested * usd_to_jocoins;
        // Atualizando carteiras
        equity_jocoins[investor] += jocoins_bought;
        equity_usd[investor] = equity_jocoins[investor] / usd_to_jocoins;
        // Atualizando numero de moedas ja compradas
        total_jocoins_bought += jocoins_bought;
    }

    // Vendendo jocoins
    function sell_jocoins(address investor, uint jocoins_sold) external 
    can_sell_jocoins(investor, jocoins_sold) {
        // Atualizando carteiras
        equity_jocoins[investor] -= jocoins_sold;
        equity_usd[investor] = equity_jocoins[investor] / usd_to_jocoins;
        // Atualizando numero de moedas ja compradas
        total_jocoins_bought -= jocoins_sold;
    }
}
