// SPDX-License-Identifier: GPL-3.0
// Version of compiler
pragma solidity >=0.7.0 <0.9.0;

//contract sdc platform??
//sdc v2: only affirmation and one objection

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
        objection objection;        // 1 objection by now
        uint current_objections;    // number of current objections
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

    event print_money( 
        address indexed _from, 
        uint256 _value 
    );

    constructor(string memory _str) payable {
        owner = payable(msg.sender);
        require(msg.value == 5, "To create an affirmation, you should pay 5 wei"); // owner needs the money to create affirmation
        createdAt = block.timestamp;
        new_a.active = true; //active during timestamp
        new_a.a_string = _str;
        new_a.current_objections = 0; //0 current objections
        contract_value = 5;
        //closedAt = createdAt + 2 days;
        closedAt = createdAt + 1 minutes; //just for testing
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
        require(new_a.objection.exist == true, "objection does not exist");
        _;
    }

    modifier can_vote(uint _num) {
        require((statement_voted[msg.sender] < _num)||(already_voted[msg.sender]==false), "cannot vote for previus statement");
        _;
    }

    modifier active {
        require(new_a.active == true, "affirmation time is done");
        _;
    }

    function get_money_owned(address _adr) external {
        emit print_money(_adr, money_owned[_adr]);
    }

    function get_statement(uint _num) external view
    objection_exist(_num) returns(string memory) {
        if(_num == 0){
            return new_a.a_string; //returns main affirmation
        }
        else{
            return new_a.objection.o_string; //returns objection
        }
    }

    function vote(uint _num) public payable
    objection_exist(_num) can_vote(_num) active() {
        require(msg.value == 1, "To vote you should pay 1 wei"); // owner needs the money to vote
        require(block.timestamp > closedAt, "affirmation expired");

        if(already_voted[msg.sender] == false)
            contract_value += 1;
        //address cannot vote for another objection
        if(_num == 0){
            new_a.votes.push(msg.sender);
        }
        else{
            new_a.objection.votes.push(msg.sender);
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
            return new_a.objection.votes.length;
        }
    }

    function current_objections() external view returns(uint) {
        return new_a.current_objections;
    }

    function create_objection(string memory _s) external payable
    not_owner() active() {
        require(msg.value == 5, "To create an objection, you should pay 5 wei"); // owner needs the money to create objection
        new_a.current_objections += 1;
        new_a.objection.o_owner = payable(msg.sender);
        new_a.objection.o_string = _s;
        new_a.objection.exist = true;
        contract_value += 5;
    }

    function evaluate_winners() private active() {
        // see who won the objection(s) and/or affirmation and update money_owned
        uint total_owned = 0;
        if(new_a.objection.votes.length > new_a.votes.length){ // objection has more votes
            // updates money_owned 
            for(uint i = 0; i < new_a.objection.votes.length; i++) {
                money_owned[new_a.objection.votes[i]] += 1;
                total_owned += 1;
            }
            money_owned[new_a.objection.o_owner] += 5;
            total_owned += 5;
        }
        else { //affirmation has more votes
            // updates money_owned 
            for(uint i = 0; i < new_a.votes.length; i++) {
                money_owned[new_a.votes[i]] += 1;
                total_owned += 1;
            }
            money_owned[owner] += 5;
            total_owned += 5;
        }
        uint dividends;
        dividends = contract_value - total_owned;
        total_owned = 0;
        if(new_a.objection.votes.length > new_a.votes.length){ // objection has more votes
            // updates money_owned
            money_owned[new_a.objection.o_owner] += dividends/2; // statement owner receives half earnings
            dividends -= (dividends/2);
            for(uint i = 0; i < new_a.objection.votes.length; i++) {
                money_owned[new_a.objection.votes[i]] += (dividends / new_a.objection.votes.length);
                total_owned += (dividends / new_a.objection.votes.length);
            }
            dividends -= total_owned;
            money_owned[new_a.objection.o_owner] += dividends; // statement owner receives leftovers
        }
        else { //affirmation has more votes
            // updates money_owned
            money_owned[owner] += dividends/2; // statement owner receives half earnings
            dividends -= (dividends/2);
            for(uint i = 0; i < new_a.votes.length; i++) {
                money_owned[new_a.votes[i]] += (dividends / new_a.votes.length);
                total_owned += (dividends / new_a.votes.length);
            }
            dividends -= total_owned;
            money_owned[owner] += dividends; // statement owner receives leftovers
        }
        contract_value = 0;
        new_a.active = false;
    }

    function should_pay() public active() {
        // test if it's time to pay dividends
        if(block.timestamp > closedAt && payed_dividends == false) 
            evaluate_winners();
    }
}
