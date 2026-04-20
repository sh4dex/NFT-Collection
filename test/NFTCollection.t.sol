//SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {NFTCollection} from "../src/NFTCollection.sol";
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract NFTCollectionTest is Test {
    address deployer = vm.addr(1);
    address seller = vm.addr(2);
    address buyer = vm.addr(3);
    address randomUser = vm.addr(4);
    uint256 tokenId = 0;
    uint256 price = 100;

    MockNFT nft;
    NFTCollection marketplace;

    function setUp() external {
        vm.startPrank(deployer);
        marketplace = new NFTCollection();
        nft = new MockNFT();
        vm.stopPrank();

        vm.startPrank(seller);
        nft.mint(seller, tokenId);
        vm.stopPrank();
    }

    function testMintNft() public view {
        address owner = nft.ownerOf(tokenId);
        assert(owner == seller);
    }

    // ************
    //test listing
    //*************
    function testShouldRevertNftOwnerListingFails() public {
        vm.startPrank(randomUser);
        vm.expectRevert("only owner can list");
        marketplace.listNft(address(nft), tokenId, price);
        vm.stopPrank();
    }

    function testShouldRevertNftByOtherUserListingFails() public {
        uint256 tokenId_ = 100;
        vm.startPrank(seller);
        nft.mint(seller, tokenId_);
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.expectRevert("only owner can list");
        marketplace.listNft(address(nft), tokenId_, price);
        vm.stopPrank();
    }

    function testShouldRevertNotValidPriceListing() public {
        uint256 notValidPrice = 0;
        vm.startPrank(seller);
        vm.expectRevert("Price can't be 0");
        marketplace.listNft(address(nft), tokenId, notValidPrice);
        vm.stopPrank();
    }

    function testShouldRevertNotValidTokenId() public {
        vm.startPrank(seller);
        vm.expectRevert();
        marketplace.listNft(address(nft), 1000, price);
        vm.stopPrank();
    }

    function testListingWorksProperly() public {
        vm.startPrank(seller);

        (address sellerBefore, , , ) = marketplace.listings(
            address(nft),
            tokenId
        );
        marketplace.listNft(address(nft), tokenId, price);
        (address sellerAfter, , , ) = marketplace.listings(
            address(nft),
            tokenId
        );

        assert(sellerBefore == address(0) && sellerAfter == seller);
        vm.stopPrank();
    }

    // **************
    //Cancel listing
    // **************

    function testShouldRevertIfNotOwner() public {
        vm.prank(seller);
        marketplace.listNft(address(nft), tokenId, price);
        vm.startPrank(randomUser);
        vm.expectRevert("Only owner can cancel");
        marketplace.cancelListing(address(nft), tokenId);
        vm.stopPrank();
    }

    function testCancelListingWorksProperly() public {
        vm.startPrank(seller);
        marketplace.listNft(address(nft), tokenId, price);
        (address sellerBefore, , , ) = marketplace.listings(
            address(nft),
            tokenId
        );
        marketplace.cancelListing(address(nft), tokenId);
        (address sellerAfter, , , ) = marketplace.listings(
            address(nft),
            tokenId
        );
        assert(sellerBefore == seller && sellerAfter == address(0));
        vm.stopPrank();
    }

    // **************
    // Buy NFT
    // **************
    function testBuyNft() public {}
}
