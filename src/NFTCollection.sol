//SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {
    Ownable
} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {
    IERC721
} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract NFTCollection is Ownable {
    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) listing;

    constructor() Ownable(msg.sender) {}

    // functions

    function listNft(
        address nftAddress_,
        uint256 tokenId_,
        uint256 price_
    ) public {
        require(price_ > 0, "Price can't be 0");
        require(
            IERC721(nftAddress_).ownerOf(tokenId_) == msg.sender,
            "only owner can list"
        );

        Listing memory listing_ = Listing({
            seller: msg.sender,
            nftAddress: nftAddress_,
            tokenId: tokenId_,
            price: price_
        });

        listing[nftAddress_][tokenId_] = listing_;
    }
    // buy
    // cancel listing
}
