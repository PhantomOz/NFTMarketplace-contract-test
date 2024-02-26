// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error TOKEN_ALREADY_LISTED();
error NOT_OWNER();
error RECIPIENT_IS_ZEROADDRESS();


contract Marketplace is ERC721 {
    uint256 private s_tokenCounter;
    mapping(uint256 => Listing) private s_tokenAddressToListing;
    mapping(uint256 => address ) private s_tokenToOwner;
    mapping(uint256 => string) private s_tokenIdToUri;

    event MintedNFT(address indexed _owner, uint256 _tokenId);
    event ListedNFT(address indexed _owner, uint256 _tokenId, uint256 _price);

    struct Listing {
        uint256 price;
        address owner;
        bool isSelling;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol){}

    function mintNft(string memory _tokenUri) external {
        s_tokenIdToUri[s_tokenCounter] = _tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        emit MintedNFT(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function listNft(uint256 _tokenId, uint256 _price) external {
        if(s_tokenAddressToListing[_tokenId].isSelling){
            revert TOKEN_ALREADY_LISTED();
        }
        if(s_tokenToOwner[_tokenId] != msg.sender){
            revert NOT_OWNER();
        }
        s_tokenAddressToListing[_tokenId] = Listing(_price, msg.sender, true);
        emit ListedNFT(msg.sender, _tokenId, _price);
    }

    function transfer(uint256 _tokenId, address _recipient) external {
        if(s_tokenToOwner[_tokenId] != msg.sender){
            revert NOT_OWNER();
        }
        if(_recipient == address(0)){
            revert RECIPIENT_IS_ZEROADDRESS(); 
        }
        _safeTransfer(msg.sender, _recipient, _tokenId);
        emit Transfer(msg.sender, _recipient, _tokenId);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        return s_tokenIdToUri[_tokenId];
    }
}