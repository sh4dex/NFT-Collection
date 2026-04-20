//SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract NFTCollection is Ownable, ReentrancyGuard {
    //TODO: Implement fees percentage
    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) listings;

    event NftListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event CanceledListing(address indexed nftAddress, uint256 indexed tokenId);
    event NftSold(
        address indexed seller,
        address indexed buyer,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 price
    );

    constructor() Ownable(msg.sender) {}

    // functions

    function listNft(
        address nftAddress_,
        uint256 tokenId_,
        uint256 price_
    ) external nonReentrant {
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

        listings[nftAddress_][tokenId_] = listing_;
        emit NftListed(msg.sender, nftAddress_, tokenId_, price_);
    }

    function buyNft(
        address nftAddress_,
        uint256 tokenId_
    ) external payable nonReentrant {
        Listing memory listing_ = listings[nftAddress_][tokenId_];
        require(
            listing_.seller != address(0) && listing_.price > 0,
            "NFT not listed for sale"
        );
        require(listing_.price == msg.value, "Incorrect payment amount");

        delete listings[nftAddress_][tokenId_];

        IERC721(nftAddress_).safeTransferFrom(
            listings[nftAddress_][tokenId_].seller,
            msg.sender,
            listing_.tokenId
        );

        (bool success, ) = listing_.seller.call{value: listing_.price}("");
        require(success, "transfer failed");
        emit NftSold(
            msg.sender,
            listing_.seller,
            listing_.nftAddress,
            listing_.tokenId,
            listing_.price
        );
    }

    function cancelListing(
        address nftAddress_,
        uint256 tokenId_
    ) external nonReentrant {
        require(listings[nftAddress_][tokenId_].seller == msg.sender);
        delete listings[nftAddress_][tokenId_];

        emit CanceledListing(nftAddress_, tokenId_);
    }
}
