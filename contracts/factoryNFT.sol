pragma solidity ^0.8.3;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FactoryNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Factory NFT", "FTN") {}

    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment(); //+1
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId); //721中的mint
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
