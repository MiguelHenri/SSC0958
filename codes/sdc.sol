// SPDX-License-Identifier: GPL-3.0
// Version of compiler
pragma solidity >=0.7.0 <0.9.0;

//contract == new affirmation
contract SDC {
    
    struct objection {
        address o_owner;
        string o_string;
        uint votes;
        bool exist;
    }

    struct affirmation {
        string a_string;
        uint votes;
        bool active;
        bool received_string;
        objection[] objections;
        uint current_objections;
    }

    //addresses (users) will have both data
    mapping(address => bool) already_voted;
    mapping(address => uint) statement_voted;

    address public owner;
    uint public createdAt;
    affirmation new_a; //contract main affirmation

    constructor() { 
        owner = msg.sender;
        createdAt = block.timestamp;
        new_a.votes = 0; //start with no votes
        new_a.active = true; //active during timestamp
        new_a.received_string = false; //string was not set yet
        new_a.current_objections = 0; //0 current objections
    }

    modifier can_set_affirmation(bool _received) {
        require(_received == false, "already set affirmation");
        _;
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

    function set_affirmation(string memory _s) external
    can_set_affirmation(new_a.received_string) is_owner() {
        new_a.received_string = true; //will not accept string changes
        new_a.a_string = _s;
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

    function vote(uint _num) public 
    objection_exist(_num) can_vote(_num) {
        if(_num == 0){
            new_a.votes += 1;
        }
        else{
            new_a.objections[_num].votes += 1;
        }
        already_voted[msg.sender] = true;
        statement_voted[msg.sender] = _num;
    }

    function get_votes(uint _num) external view
    objection_exist(_num) returns(uint) { 
        if(_num == 0){
            return new_a.votes;
        }
        else{
            return new_a.objections[_num].votes;
        }
    }

    function current_objections() external view returns(uint) {
        return new_a.current_objections;
    }

    function create_objection(string memory _s) public 
    not_owner() {
        new_a.current_objections += 1;
        new_a.objections[new_a.current_objections].o_owner = msg.sender;
        new_a.objections[new_a.current_objections].o_string = _s;
        new_a.objections[new_a.current_objections].votes = 0;
        new_a.objections[new_a.current_objections].exist = true;
    }

    function delete_objection(uint _num) private
    objection_exist(_num) {
        new_a.current_objections -= 1;
        new_a.objections[_num].o_owner = address(0);
        new_a.objections[_num].o_string = "";
        new_a.objections[_num].votes = 0;
        new_a.objections[_num].exist = false;
    }
}
