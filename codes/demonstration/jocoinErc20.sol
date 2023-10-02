// Code based on jocoins ICO https://github.com/hagenderouen/mini-chain/blob/master/hadcoins_ico.sol
// SPDX-License-Identifier: GPL-3.0

// Version of compiler
pragma solidity >=0.7.0 <0.9.0;

contract jocoinErc20 {

    // Mapeamento do endereço do investidor para seu patrimônio em jocoins e em USD
    mapping(address => uint256) private equity_jocoins;
    mapping(address => uint256) private equity_usd;

    // Padrão Erc20
    // Número máximo de jocoins à venda
    uint256 private _totalSupply;
    // Nome do token
    string private _name;
    // Sigla do token
    string private _symbol;

    // Construtor, seta variáveis
    constructor() {
        _name = "Jocoin";
        _symbol = "JOC";
        _totalSupply = 1e6;
    }

    // Taxa de conversão de USD para jocoins
    uint256 private usd_to_jocoins = 1000;

    // Total de jocoins que foram comprados por investidores
    uint256 private total_jocoins_bought = 0;

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
    function balanceOf(address _account) public view returns(uint256) {
        return equity_jocoins[_account];
    }

    event Transfer(address indexed _sender, address indexed _receiver, uint256 _value);

    // Erc20 Transfer
    function transfer(address _to, uint256 value) public
    can_transact_jocoins(msg.sender, value) returns(bool) {
        if (_to == address(0) || msg.sender == address(0)) return false;
        // atualiza carteiras
        equity_jocoins[msg.sender] -= value;
        equity_usd[msg.sender] -= value / usd_to_jocoins;
        equity_jocoins[_to] += value;
        equity_usd[_to] += value / usd_to_jocoins;
        // evento
        emit Transfer(msg.sender, _to, value);
        return true;
    }

    // Verificando se um investidor pode comprar jocoins
    modifier can_buy_jocoins(uint256 usd_invested) {
        require (usd_invested * usd_to_jocoins + total_jocoins_bought <= _totalSupply, "jocoins indisponiveis");
        _;
    }

    // Verificando se um investidor pode vender/transferir jocoins
    modifier can_transact_jocoins(address investor, uint256 jocoins_sold) {
        // Retirada de, no máximo, 10% do saldo
        require (jocoins_sold <= equity_jocoins[investor]*9/10, "valor maior que 90% do saldo");
        // Venda apenas após as 22h
        uint256 _time = block.timestamp - 3*60*60; // mudando para BRT
        _time = _time % (24*60*60); // horario em segundos
        require (_time <= 22*60*60, "a venda/transferencia so eh permitida ate as 22h");
        _;
    }

    // Comprando jocoins
    function buy_jocoins(address investor, uint256 usd_invested) external
    can_buy_jocoins(usd_invested) {
        // Convertendo de USD para Jocoin
        uint256 jocoins_bought = usd_invested * usd_to_jocoins;
        // Atualizando carteiras
        equity_jocoins[investor] += jocoins_bought;
        equity_usd[investor] = equity_jocoins[investor] / usd_to_jocoins;
        // Atualizando numero de moedas ja compradas
        total_jocoins_bought += jocoins_bought;
    }

    // Vendendo jocoins
    function sell_jocoins(address investor, uint256 jocoins_sold) external 
    can_transact_jocoins(investor, jocoins_sold) {
        // Atualizando carteiras
        equity_jocoins[investor] -= jocoins_sold;
        equity_usd[investor] = equity_jocoins[investor] / usd_to_jocoins;
        // Atualizando numero de moedas ja compradas
        total_jocoins_bought -= jocoins_sold;
    }
}
