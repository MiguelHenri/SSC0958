// SPDX-License-Identifier: GPL-3.0
// Version of compiler
pragma solidity >=0.7.0 <0.9.0;

//contract == new affirmation
contract SDC {
    
    struct objection {
        string o_string;
        uint votes;
    }

    struct affirmation {
        string a_string;
        uint votes;
        bool active;
        bool received_string;
        objection[] objections;
        uint current_objections;
    }

    address public owner;
    uint public createdAt;
    affirmation new_a; //contract main affirmation

    constructor(){
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

    function set_affirmation(string memory _s) external
    can_set_affirmation(new_a.received_string) is_owner() {
        new_a.received_string = true; //will not accept string changes
        new_a.a_string = _s;
    }

    function get_affirmation() external view returns(string memory){
        return new_a.a_string; //returns main affirmation
    }

    function vote(uint _num) public {
        /*will require that [_num] objections exists*/
        /*will require if user already voted in any objection/affirmation in this contract*/
        if(_num == 0){
            new_a.votes += 1;
        }
        else{
            new_a.objections[_num].votes += 1;
        }
    }

    function get_votes(uint _num) external view returns(uint){
        /*will require that [_num] objections exists*/
        if(_num == 0){
            return new_a.votes;
        }
        else{
            return new_a.objections[_num].votes;
        }
    }

}
