// SPDX-License-Identifier: UNLICENSED
pragma solidity  ^0.8.27;

contract VendingMachine3 {
    // payable keyword allows the address to reciever Ether
    address payable public owner;  
    
    uint public ownerBalance;

    enum ProductCategories {FOODS,DRINKS}

    // defining the attributes of the product in the vending machine
    struct Product {
        string name;
        uint256 price;
        uint256 stock;
        string image;
    }

    // attributes of transactions
    struct Transaction {
        address buyer; // address of the person who made the purchase
        string productName;
        uint256 price;
    }
   
//    attributes of Customer bag
    struct CustomerBag{
        string productName;
        uint256 price;
        string image;
        uint256 buyDate;
    }

    Transaction[]public transactions;

    // product mapping
    mapping (ProductCategories => Product[]) public VendingMachine;
    
    // customer Bag Mapping
    mapping(address=>CustomerBag[]) public customerBags;

    // event to log when a product is added or stock is updated
    event ProductUpdated(ProductCategories category,string productName,uint256 stock);

    // event to log when a product is purchased
    event ProductPurchased(address buyer,string productName,uint price);

    constructor (){
        //msg.sender -> global variable that holds the address of the user or contract that is trying to execute a function
    
        owner = payable(msg.sender);
    }

    // modifier to allow only the owner to call specific functions
    modifier onlyOwner(){
        /** 
            owner -> holds the address of the owner of the contract
            require checks that the msg.sender is the same as the owner
           (_) -> is placeholder represents execution of the rest of the code 
        */
        require(msg.sender == owner,"Only the owner can perform this");
        _; // this ensures that the function will only execute after the require check passes
    }
     
    //  memory keyword -> variables declared with memory are temporary and exist during the execution  of the function, at the end of the execution the memory is cleared (data is not stored in the blockchain)
    // storage ->variables stored in storage are persistent and exist on the blockchain (retain their value btwn function calls and transactions)
    function setProduct(ProductCategories _category
    ,string memory _name,uint256 _price,uint256 _stock,string memory _image) public onlyOwner{
        bool productExists = false;

        // checking if the product exists
        for (uint256 i = 0; i < VendingMachine[_category].length; i++) {
 
            /**
              **kecca256 - hashing function(its a one-way function )
              uses:
                used for securing data 
                generating unique identifiers
                validating data integrity

              input data - bytes
             */
            
           
            if(keccak256(bytes(VendingMachine[_category][i].name))== keccak256(bytes(_name))){
                // it the product exists then update it
                VendingMachine[_category][i].stock += _stock;
                VendingMachine[_category][i].price = _price;
                productExists = true;
                break;
            }
        }

        if(!productExists){
            VendingMachine[_category].push(Product(_name,_price,_stock,_image));
        }

        // emit the product update
        emit ProductUpdated(_category, _name, _stock);
    }

    // making a purchase
    function PurchaseProduct(ProductCategories _category,uint _index) public payable {
        Product storage product = VendingMachine[_category][_index];
        // ensure the product is in stock
        require(product.stock > 0,"Product out of stock");

        // ensure the buyer has sent enough Ether

        /**
          msg.value -> global variable that represents the amount of Ether sent along with a transaction
         */
        require(msg.value >= product.price,"Insuffient funds");

        product.stock -=1;
        owner.transfer(msg.value); //transfer the Ether to the owner

        // record the transcation

        transactions.push(Transaction({
            buyer:msg.sender,
            productName:product.name,
            price:msg.value
        }));

        customerBags[msg.sender].push(CustomerBag(product.name, product.price, product.image, block.timestamp));


        emit ProductPurchased(msg.sender, product.name, msg.value);
    }

    // withdrawal to user account
    function withdrawalBalance() public onlyOwner{
        uint256 balance = address(this).balance;

        require(balance >0 ,"No funds available to withdrawal");

        // transfer contract balance to the owner
        owner.transfer(balance);
    }

    // getting details of a single product
    function getProduct(ProductCategories _categories,uint256 _index) public view returns(string memory,uint256,uint256,string memory){
        Product memory product = VendingMachine[_categories][_index];
        return (product.name,product.price,product.stock,product.image);
    }

    // getting user's bag
    function getCustomerBag(address _customerAddress) public view returns(CustomerBag [] memory) {
          return customerBags[_customerAddress];
    }

}