// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract NFTMarketplace {
    uint256 public feePercentage = 5; // 0.05% fee
    address public feeRecipient;

    event NFTPurchased(address indexed buyer, address indexed seller, uint256 tokenId, uint256 price, uint256 fee);

    constructor(address _feeRecipient) {
        feeRecipient = _feeRecipient;
    }

    function buyNFT(address nftContract, uint256 tokenId, address seller, uint256 price) external payable {
        require(msg.value >= price, "Insufficient funds sent");
        require(IERC721(nftContract).ownerOf(tokenId) == seller, "Seller is not the owner");

        // Calculate the fee
        uint256 fee = (price * feePercentage) / 10000;
        uint256 sellerAmount = price - fee;

        // Transfer the NFT to the buyer
        IERC721(nftContract).transferFrom(seller, msg.sender, tokenId);

        // Transfer the price to the seller
        payable(seller).transfer(sellerAmount);

        // Transfer the fee to the fee recipient
        payable(feeRecipient).transfer(fee);

        emit NFTPurchased(msg.sender, seller, tokenId, price, fee);
    }
}