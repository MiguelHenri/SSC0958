// SPDX-License-Identifier: GPL-3.0
// Version of compiler
pragma solidity >=0.7.0 <0.9.0;

//contract sdc platform??
//responsable of deleting objections and transferring coins

//contract == new affirmation
contract sdc {

    struct objection {
        address payable o_owner;    // who stated this objection
        uint closedAt;              // when should it be closed
        string o_string;            // objection statement
        address[] votes;            // who has voted for this one
        bool exist;                 // is currently receiving votes?
        bool winner;                // is winner?
    }

    struct affirmation {
        string a_string;            // who stated this affirmation
        address[] votes;            // who has voted for this one
        bool active;                // is active?
        objection[100] objections;  // max 100 objections by now
        uint current_objections;    // current objections
    }

    //addresses (users) will have both data
    mapping(address => bool) already_voted;     // logs which users have voted
    mapping(address => uint) statement_voted;   // logs in which statement they've voted to
    mapping(address => uint) money_owned;       // logs how much money is owned to each person

    address payable public owner;   // who stated this affirmation
    uint public createdAt;          // when it was created
    uint public closedAt;           // when it should close
    affirmation new_a;              //contract main affirmation
    address[] voters;               // who has voted in this contract (affirmation + objections)
    uint public contract_value;     // how much money this contract is holding
    bool public payed_dividends;    // has this contract payed its dividends?


    constructor(string memory _str) payable {
        owner = payable(msg.sender);
        require(msg.value == 5, "To create an affirmation, you should pay 5 wei"); // owner needs the money to create affirmation
        createdAt = block.timestamp;
        new_a.active = true; //active during timestamp
        new_a.a_string = _str;
        new_a.objections[0].exist = true;
        new_a.current_objections = 0; //0 current objections
        contract_value = 5;
        closedAt = createdAt + 2 days;
        //closedAt = createdAt + 20 seconds; //just for testing
    }

    modifier is_owner() {
        require(msg.sender == owner, "do not own affirmation contract");
        _;
    }

    modifier not_owner() {
        require(msg.sender != owner, "own main affirmation");
        _;
    }

    modifier objection_exist(uint _num) {
        require(new_a.objections[_num].exist == true, "objection does not exist");
        _;
    }

    modifier can_vote(uint _num) {
        require((statement_voted[msg.sender] < _num)||(already_voted[msg.sender]==false), "cannot vote for previus statement");
        _;
    }

    function get_statement(uint _num) external view
    objection_exist(_num) returns(string memory) {
        if(_num == 0){
            return new_a.a_string; //returns main affirmation
        }
        else{
            return new_a.objections[_num].o_string; //returns objection[_num]
        }
    }

    function vote(uint _num) public payable
    objection_exist(_num) can_vote(_num) {
        require(msg.value == 1, "To vote you should pay 1 wei"); // owner needs the money to vote
        if(already_voted[msg.sender] == false)
            contract_value += 1;
        //address cannot vote for another objection
        if(_num == 0){
            new_a.votes.push(msg.sender);
        }
        else{
            new_a.objections[_num].votes.push(msg.sender);
        }
        already_voted[msg.sender] = true;
        statement_voted[msg.sender] = _num;
        voters.push(msg.sender);
    }

    function get_votes(uint _num) external view
    objection_exist(_num) returns(uint) {
        if(_num == 0){
            return new_a.votes.length;
        }
        else{
            return new_a.objections[_num].votes.length;
        }
    }

    function current_objections() external view returns(uint) {
        return new_a.current_objections;
    }

    function create_objection(string memory _s) external payable
    not_owner() {
        require(msg.value == 5, "To create an objection, you should pay 5 wei"); // owner needs the money to create objection
        new_a.current_objections += 1;
        new_a.objections[new_a.current_objections].o_owner = payable(msg.sender);
        new_a.objections[new_a.current_objections].o_string = _s;
        new_a.objections[new_a.current_objections].exist = true;
        contract_value += 5;
    }

    function delete_objection(uint _num) private
    objection_exist(_num) {
        /*will be called privately by contract when objection timestamp is done*/
        new_a.current_objections -= 1;
        new_a.objections[_num].exist = false;
    }

    function pay_dividends() private {
        payed_dividends = true;
        evaluate_winners();
        for(uint i = 0; i < voters.length; i++) { // pay winner voters the money they've put in
            payable(voters[i]).transfer(money_owned[voters[i]]);
            contract_value -= money_owned[voters[i]];
        }
        // pays half the profit (losers' money) to owner
        owner.transfer(contract_value / 2);
        contract_value /= 2;

        for(uint i = 0; i < new_a.votes.length; i++) { //distributes the rest of the profit to voters of the winning affirmation
            payable(new_a.votes[i]).transfer(contract_value / new_a.votes.length);
            contract_value -= (contract_value / new_a.votes.length);
        }
    }

    function evaluate_winners() private {
        // see who won the objection(s) and/or affirmation and update money_owned
    }

    function should_pay() public {
        // test if it's time to pay dividends
        if(block.timestamp > closedAt && payed_dividends == false)
            pay_dividends();
    }
}

