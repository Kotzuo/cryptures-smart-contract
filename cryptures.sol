// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./openzeppelin-contracts/contracts/utils/Context.sol";
import "./openzeppelin-contracts/contracts/utils/Counters.sol";

contract Cryptures is Context, ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    address private _owner;

    enum CrypturesType {Water, Fire, Grass, Random}

    struct CryptureInfo {
        uint256 id;
        uint8 level;
        uint256 xp;
        uint48 fedDate;
        uint48 washedDate;
        uint8[4] attacks;
    }

    mapping(uint256 => CryptureInfo) private _crypturesInfo;

    constructor(string memory baseTokenURI) ERC721("Crypture", "CRPT") {
        _baseTokenURI = baseTokenURI;
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function mint(address to, CrypturesType cryptureType) public onlyOwner {
        uint256 id = _tokenIdTracker.current();

        _mint(to, id);

        uint256 cryptureId =
            cryptureType == CrypturesType.Random
                ? uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender))
                ) % 3
                : uint256(cryptureType);

        uint8[4] memory attacks = [1, 2, 0, 0];
        if (cryptureId == uint256(CrypturesType.Fire)) {
            attacks = [1, 3, 0, 0];
        } else if (cryptureId == uint256(CrypturesType.Water)) {
            attacks = [1, 4, 0, 0];
        }

        _crypturesInfo[id] = CryptureInfo(
            cryptureId,
            1,
            0,
            uint48(block.timestamp),
            uint48(block.timestamp),
            attacks
        );

        _tokenIdTracker.increment();
    }

    function washCreatureFromId(uint256 id) public onlyOwner returns (uint256) {
        uint256 lastWashedDate = _crypturesInfo[id].washedDate;
        _crypturesInfo[id].washedDate = uint48(block.timestamp);

        return lastWashedDate;
    }

    function feedCreatureFromId(uint256 id) public onlyOwner returns (uint256) {
        require(
            block.timestamp - _crypturesInfo[id].fedDate <= 1 days,
            "Cryptures: Crypture already ran away! Refund in Cherish is available."
        );

        uint256 lastFedDate = _crypturesInfo[id].fedDate;
        _crypturesInfo[id].fedDate = uint48(block.timestamp);

        return lastFedDate;
    }

    function getCryptureInfo(uint256 id)
        public
        view
        returns (CryptureInfo memory)
    {
        return _crypturesInfo[id];
    }

    function forceBurn(uint256 id) public onlyOwner {
        _burn(id);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
