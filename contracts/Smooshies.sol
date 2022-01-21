// SPDX-License-Identifier: MIT
/*
+ + + - - - - - - - - - - - - - - - - - - - - - - - - - - - ++ - - - - - - - - - - - - - - - - - - - - - - - - - - + + +
+                                                                                                                      +
+                                                                                                                      +
.                                                                                                                      .
   SSSSSSSSSSSSSSS                                                                            
 SS:::::::::::::::S                                                                           
S:::::SSSSSS::::::S                                                                           
S:::::S     SSSSSSS                                                                           
S:::::S               mmmmmmm    mmmmmmm      ooooooooooo      ooooooooooo       ssssssssss   
S:::::S             mm:::::::m  m:::::::mm  oo:::::::::::oo  oo:::::::::::oo   ss::::::::::s  
 S::::SSSS         m::::::::::mm::::::::::mo:::::::::::::::oo:::::::::::::::oss:::::::::::::s 
  SS::::::SSSSS    m::::::::::::::::::::::mo:::::ooooo:::::oo:::::ooooo:::::os::::::ssss:::::s
    SSS::::::::SS  m:::::mmm::::::mmm:::::mo::::o     o::::oo::::o     o::::o s:::::s  ssssss 
       SSSSSS::::S m::::m   m::::m   m::::mo::::o     o::::oo::::o     o::::o   s::::::s      
            S:::::Sm::::m   m::::m   m::::mo::::o     o::::oo::::o     o::::o      s::::::s   
            S:::::Sm::::m   m::::m   m::::mo::::o     o::::oo::::o     o::::ossssss   s:::::s 
SSSSSSS     S:::::Sm::::m   m::::m   m::::mo:::::ooooo:::::oo:::::ooooo:::::os:::::ssss::::::s
S::::::SSSSSS:::::Sm::::m   m::::m   m::::mo:::::::::::::::oo:::::::::::::::os::::::::::::::s 
S:::::::::::::::SS m::::m   m::::m   m::::m oo:::::::::::oo  oo:::::::::::oo  s:::::::::::ss  
 SSSSSSSSSSSSSSS   mmmmmm   mmmmmm   mmmmmm   ooooooooooo      ooooooooooo     sssssssssss    
                                                                                              
                                                                                              
                                                                                              
                                                                                              
                                                                                              
                                                                                              
                                                                                              
                                                                 
                                                                 
hhhhhhh               iiii                                       
h:::::h              i::::i                                      
h:::::h               iiii                                       
h:::::h                                                          
 h::::h hhhhh       iiiiiii     eeeeeeeeeeee        ssssssssss   
 h::::hh:::::hhh    i:::::i   ee::::::::::::ee    ss::::::::::s  
 h::::::::::::::hh   i::::i  e::::::eeeee:::::eess:::::::::::::s 
 h:::::::hhh::::::h  i::::i e::::::e     e:::::es::::::ssss:::::s
 h::::::h   h::::::h i::::i e:::::::eeeee::::::e s:::::s  ssssss 
 h:::::h     h:::::h i::::i e:::::::::::::::::e    s::::::s      
 h:::::h     h:::::h i::::i e::::::eeeeeeeeeee        s::::::s   
 h:::::h     h:::::h i::::i e:::::::e           ssssss   s:::::s 
 h:::::h     h:::::hi::::::ie::::::::e          s:::::ssss::::::s
 h:::::h     h:::::hi::::::i e::::::::eeeeeeee  s::::::::::::::s 
 h:::::h     h:::::hi::::::i  ee:::::::::::::e   s:::::::::::ss  
 hhhhhhh     hhhhhhhiiiiiiii    eeeeeeeeeeeeee    sssssssssss    
                                                                            .
+                                                                                                                      +
+                                                                                                                      +
+ + + - - - - - - - - - - - - - - - - - - - - - - - - - - - ++ - - - - - - - - - - - - - - - - - - - - - - - - - - + + +
*/
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Smooshies is ERC721Enumerable, Ownable, PaymentSplitter {
    using Strings for uint256;

    bool public saleIsActive = false;
    bool public isAllowListActive = false;
    bool public paused = false;

    string public baseTokenURI;

    uint256 public constant MAX_SUPPLY = 25;
    uint256 public constant MAX_PUBLIC_MINT = 3;

	uint256 private price = 0.1 ether;

    bool public revealed = false;
    string public notRevealedUri;

    mapping(address => uint8) private _allowList;

	//share settings
	address[] private addressList = [
	0x55c0f20123862aD1F6C1B235D06cCb5ebBe97414,
	0x320866337fEBaC0414E54bA5e70453C912BB5124
	];
	uint[] private shareList = [20,80];

	constructor(
	string memory _name,
	string memory _symbol,
	string memory _initBaseURI
	) ERC721(_name, _symbol)
	PaymentSplitter( addressList, shareList ){
	setBaseURI(_initBaseURI);
	}

    //public mint function
    function mint(uint numberOfTokens) public payable {
        uint256 ts = totalSupply();
        require(!paused);
        require(saleIsActive, "Sale must be active to mint tokens");
        require(numberOfTokens <= MAX_PUBLIC_MINT, "Exceeded max token purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(price * numberOfTokens <= msg.value, "Ether value sent is not correct");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    //presale mint function
    function mintAllowList(uint8 numberOfTokens) external payable {
        uint256 ts = totalSupply();
        require(!paused);
        require(isAllowListActive, "Allow list is not active");
        require(numberOfTokens <= _allowList[msg.sender], "Exceeded max available to purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(price * numberOfTokens <= msg.value, "Ether value sent is not correct");

        _allowList[msg.sender] -= numberOfTokens;
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    //reserve mint for team
    function reserve(uint256 n) public onlyOwner {
      uint supply = totalSupply();
      uint i;
      for (i = 0; i < n; i++) {
          _safeMint(msg.sender, supply + i);
      }
    }

    //set URI
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
	    baseTokenURI = _newBaseURI;
	}

    //view URI
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    //set URI for pre-reveal NFTs
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(tokenId <= MAX_SUPPLY);


        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0	? string(abi.encodePacked(currentBaseURI, tokenId.toString())) : "";
	}

      //set reveal to true
    function reveal() public onlyOwner {
        revealed = true;
    }
  

    //set WL address array
    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

	//price switch
	function setPrice(uint256 _newPrice) public onlyOwner {
	    price = _newPrice;
	}

    //max for a wallet to mint
    function numAvailableToMint(address addr) external view returns (uint8) {
        return _allowList[addr];
    }

    //pause the minting if needed
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    //on / off switch for sale
    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    //on / off switch for presale
    function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    //withdraw funds
	function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
	}
}