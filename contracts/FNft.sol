// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FNft is ERC1155, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    
    uint256 public constant PRICE_PER_TOKEN = 0.05 ether;

    struct Trait{
        string name;
        uint8  speed;
    }
    mapping(uint => Trait) public tokenTraits;

    /** */
    event NftMinted(address indexed to, uint id, string name, uint8 speed);


    constructor() ERC1155("") {}

    /**
     * Mint new nft with traits
     */
    function mint(string memory name, uint8 speed) public payable {
        require(PRICE_PER_TOKEN <= msg.value, "Ether value sent is not correct");

        uint tokenId = _tokenIds.current();
        _mint(_msgSender(), tokenId, 1, "");
        tokenTraits[tokenId] = Trait(name, speed);

        emit NftMinted(_msgSender(), tokenId, name, speed);
        _tokenIds.increment();
    }
    
    /**
     * @dev returns total number of NFT
     */
    function totalCount() external view returns(uint) {
        return _tokenIds.current();
    }
}