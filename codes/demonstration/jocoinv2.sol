// Code based on jocoins ICO https://github.com/hagenderouen/mini-chain/blob/master/hadcoins_ico.sol

// Version of compiler
pragma solidity ^0.5.0;

contract jocoin_ico {

    // Imprimindo o número máximo de jocoins à venda
    uint public max_jocoins = 1000000;

    // Imprimindo a taxa de conversão de USD para jocoins
    uint public usd_to_jocoins = 1000;

    // Imprimindo o número total de jocoins que foram comprados por investidores
    uint public total_jocoins_bought = 0;

    // Mapeamento do endereço do investidor para seu patrimônio em jocoins para USD
    mapping(address => uint) equity_jocoins;
    mapping(address => uint) equity_usd;

    // Verificando se um investidor pode comprar jocoins
    modifier can_buy_jocoins(uint usd_invested) {
        require (usd_invested * usd_to_jocoins + total_jocoins_bought <= max_jocoins, "jocoins indisponíveis");
        _;
    }

    // Verificando se um investidor pode vender jocoins
    modifier can_sell_jocoins(address investor, uint jocoins_sold) {
        // Retirada de, no máximo, 10% do saldo
        require (jocoins_sold <= equity_jocoins[investor]/10, "valor maior que 10% do saldo");
        // Venda apenas após as 22h
        uint _time = block.timestamp % (24*60*60); // horario em segundos
        require (_time >= 22*60*60, "a venda só é permitida após as 22h");
        _;
    }

    // Obtendo o patrimônio em jocoins de um investidor
    function equity_in_jocoins(address investor) external view returns (uint) {
        return equity_jocoins[investor];
    }

    // Obtendo o patrimônio em dólares de um investidor
    function equity_in_usd(address investor) external view returns (uint) {
        return equity_usd[investor];
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
