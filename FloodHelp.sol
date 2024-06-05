// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

struct Request {
    uint id;
    address author;
    string title;
    string description;
    string contact;
    uint timestamp;
    uint goal;
    uint balance;
    bool open;
}

contract FloodHelp {

    uint public lastId = 0;
    mapping(uint => Request) public requests;

    function openRequest(string memory title, string memory description, string memory contact, uint goal) public {
        lastId++;
        bytes memory tempEmptyStringTest = bytes(title); // Uses memory
        
        require(getOpenRequestsAuthor(msg.sender), unicode"Já existe um doação aberta para este autor");
        require(tempEmptyStringTest.length == 0, unicode"Titulo é obrigatório");

        tempEmptyStringTest = bytes(description); 
        require(tempEmptyStringTest.length == 0, unicode"A descrição é obrigatória");

        tempEmptyStringTest = bytes(contact); 
        require(tempEmptyStringTest.length == 0, unicode"Contato é obrigatória");

        requests[lastId] = Request({
            id: lastId,
            title: title,
            description: description,
            contact: contact,
            goal: goal,
            balance: 0,
            timestamp: block.timestamp,
            author: msg.sender,
            open: true
        });
    }

    function closeRequest(uint id) public {
        address author = requests[id].author;
        uint balance = requests[id].balance;
        uint goal = requests[id].goal;
        require(requests[id].open && (msg.sender == author || balance >= goal), unicode"Você não pode fechar este pedido");

        requests[id].open = false;

        if(balance > 0){
            requests[id].balance = 0;
            payable(author).transfer(balance);
        }
    }

    function donate(uint id) public payable {
        requests[id].balance += msg.value;

        require(requests[id].balance == 0, unicode"O valor da doação não pode ser zero !");

        if(requests[id].balance >= requests[id].goal)
            closeRequest(id);
    }

    function getOpenRequests(uint startId, uint quantity) public view returns (Request[] memory){              
        Request[] memory result = new Request[](quantity);
        uint id = startId;
        uint count = 0;

        do {
            if(requests[id].open){
                result[count] = requests[id];
                count++;
            }

            id++;
        }
        while(count < quantity && id <= lastId);

        return result;
    }

    function getOpenRequestsAuthor(address author) public view returns (bool){
        uint id = 1;
        bool result = false;

        do {
            if(requests[id].open){
                if(requests[id].author == author)
                {
                    result = true;
                }                 
            }

            id++;
        }
        while(id <= lastId);

        return result;
    }
}
