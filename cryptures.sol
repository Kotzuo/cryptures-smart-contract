// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./openzeppelin-contracts/contracts/utils/Context.sol";
import "./openzeppelin-contracts/contracts/utils/Counters.sol";

contract Cryptures is Context, ERC721Enumerable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    address private _owner;

    enum CrypturesType {Water, Fire, Grass, Random}

    struct CryptureInfo {
        uint256 id;
        uint256 level;
        uint256 xp;
        uint256 wins;
        uint256 losses;
        uint256 fedDate;
        uint256 washedDate;
        uint8[] attacks;
    }

    struct MinMax {
        uint256 min;
        uint256 max;
    }

    struct CryptureBaseStats {
        CrypturesType cryptureType;
        MinMax healthPoints;
        MinMax attack;
        MinMax defense;
        MinMax speed;
        MinMax specialAttack;
        MinMax specialDefense;
    }

    enum CrypturesAttackType {Normal, Grass, Fire, Water}

    struct CrypturesAttack {
        string name;
        CrypturesAttackType attackType;
        uint256 power;
        uint256 precision;
        uint256 timesToUse;
    }

    mapping(uint256 => CryptureBaseStats) private _crypturesBaseStats;
    mapping(uint256 => CryptureInfo) private _crypturesInfo;

    mapping(CrypturesType => uint256[]) private _crypturesIdByType;

    CrypturesAttack[4] private _crypturesAttacks;
    mapping(CrypturesType => uint8[]) private _crypturesAttackIdByType;

    constructor(string memory baseTokenURI) ERC721("Crypture", "CRPT") {
        _baseTokenURI = baseTokenURI;
        _owner = _msgSender();

        _crypturesBaseStats[0] = CryptureBaseStats(
            CrypturesType.Grass,
            MinMax(45, 200),
            MinMax(49, 92),
            MinMax(49, 92),
            MinMax(65, 191),
            MinMax(65, 191),
            MinMax(45, 85)
        );
        _crypturesBaseStats[1] = CryptureBaseStats(
            CrypturesType.Fire,
            MinMax(39, 188),
            MinMax(52, 98),
            MinMax(43, 81),
            MinMax(60, 112),
            MinMax(50, 94),
            MinMax(65, 121)
        );
        _crypturesBaseStats[2] = CryptureBaseStats(
            CrypturesType.Water,
            MinMax(44, 198),
            MinMax(48, 90),
            MinMax(65, 121),
            MinMax(50, 94),
            MinMax(64, 119),
            MinMax(43, 81)
        );

        _crypturesIdByType[CrypturesType.Grass] = [0];
        _crypturesIdByType[CrypturesType.Fire] = [1];
        _crypturesIdByType[CrypturesType.Water] = [2];

        _crypturesAttacks[0] = CrypturesAttack(
            "Tackle",
            CrypturesAttackType.Normal,
            40,
            100,
            35
        );

        _crypturesAttacks[1] = CrypturesAttack(
            "Vine Whip",
            CrypturesAttackType.Grass,
            45,
            100,
            25
        );

        _crypturesAttacks[2] = CrypturesAttack(
            "Ember",
            CrypturesAttackType.Fire,
            40,
            100,
            25
        );

        _crypturesAttacks[3] = CrypturesAttack(
            "Water Gun",
            CrypturesAttackType.Water,
            40,
            100,
            25
        );

        _crypturesAttackIdByType[CrypturesType.Grass] = [0, 1];
        _crypturesAttackIdByType[CrypturesType.Fire] = [0, 2];
        _crypturesAttackIdByType[CrypturesType.Water] = [0, 3];
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function mint(address to, CrypturesType cryptureType)
        public
        virtual
        onlyOwner
    {
        uint256 id = _tokenIdTracker.current();

        _mint(to, id);

        if (cryptureType != CrypturesType.Random) {
            uint256 randomIndex =
                uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender))
                ) % _crypturesIdByType[cryptureType].length;
            uint256 randomCryptureId =
                _crypturesIdByType[cryptureType][randomIndex];

            _crypturesInfo[id] = CryptureInfo(
                randomCryptureId,
                1,
                0,
                0,
                0,
                block.timestamp,
                block.timestamp,
                _crypturesAttackIdByType[cryptureType]
            );
        } else {
            CrypturesType randomType =
                CrypturesType(
                    uint256(
                        keccak256(abi.encodePacked(block.timestamp, msg.sender))
                    ) % 4
                );
            uint256 randomIndex =
                uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender))
                ) % _crypturesIdByType[randomType].length;
            uint256 randomCryptureId =
                _crypturesIdByType[randomType][randomIndex];

            _crypturesInfo[id] = CryptureInfo(
                randomCryptureId,
                1,
                0,
                0,
                0,
                block.timestamp,
                block.timestamp,
                _crypturesAttackIdByType[randomType]
            );
        }

        _tokenIdTracker.increment();
    }

    function washCreatureFromId(uint256 id) public returns (uint256) {
        uint256 lastWashedDate = _crypturesInfo[id].washedDate;
        _crypturesInfo[id].washedDate = block.timestamp;

        return lastWashedDate;
    }

    function feedCreatureFromId(uint256 id) public returns (uint256) {
        uint256 lastFedDate = _crypturesInfo[id].fedDate;
        _crypturesInfo[id].fedDate = block.timestamp;

        return lastFedDate;
    }

    function getCryptureInfo(uint256 id)
        public
        view
        returns (CryptureInfo memory)
    {
        return _crypturesInfo[id];
    }

    function getCryptureAttack(uint256 id)
        public
        view
        returns (CrypturesAttack memory)
    {
        return _crypturesAttacks[id];
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
