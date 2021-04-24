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
    enum CryptureAttackType {Normal, Grass, Fire, Water}
    enum CryptureAttackCategory {Physical, Special}

    struct MinMax {
        uint256 min;
        uint256 max;
    }
    struct FirstSecond {
        uint256 first;
        uint256 second;
    }

    struct CryptureInfo {
        uint256 id;
        uint8 level;
        uint256 xp;
        uint256 wins;
        uint256 losses;
        uint256 fedDate;
        uint256 washedDate;
        uint8[] attacks;
    }
    struct CryptureCompleteInfo {
        uint256 id;
        uint8 level;
        uint256 xp;
        uint256 wins;
        uint256 losses;
        uint256 fedDate;
        uint256 washedDate;
        CrypturesType cryptureType;
        uint256 healthPoints;
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 specialAttack;
        uint256 specialDefense;
        CryptureAttack[] attacks;
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
    struct CryptureStats {
        CrypturesType cryptureType;
        uint256 healthPoints;
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 specialAttack;
        uint256 specialDefense;
    }

    struct CryptureBattleRoundInfo {
        FirstSecond cryptureChosenAttackId;
        FirstSecond cryptureAttackDamage;
        FirstSecond cryptureHealthPoints;
    }
    struct CryptureBattleResultDetails {
        address winnerAddress;
        CryptureCompleteInfo firstCryptureCompleteInfo;
        CryptureCompleteInfo secondCryptureCompleteInfo;
        CryptureBattleRoundInfo[50] roundsInfo;
    }

    struct CryptureAttack {
        string name;
        CryptureAttackType attackType;
        CryptureAttackCategory category;
        uint256 power;
        uint256 precision;
        uint256 timesToUse;
    }

    mapping(uint256 => CryptureBaseStats) private _crypturesBaseStats;
    mapping(uint256 => CryptureInfo) private _crypturesInfo;

    mapping(CrypturesType => uint256[]) private _crypturesIdByType;

    CryptureAttack[4] private _crypturesAttacks;
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

        _crypturesAttacks[0] = CryptureAttack(
            "Tackle",
            CryptureAttackType.Normal,
            CryptureAttackCategory.Physical,
            40,
            100,
            35
        );

        _crypturesAttacks[1] = CryptureAttack(
            "Vine Whip",
            CryptureAttackType.Grass,
            CryptureAttackCategory.Physical,
            45,
            100,
            25
        );

        _crypturesAttacks[2] = CryptureAttack(
            "Ember",
            CryptureAttackType.Fire,
            CryptureAttackCategory.Special,
            40,
            100,
            25
        );

        _crypturesAttacks[3] = CryptureAttack(
            "Water Gun",
            CryptureAttackType.Water,
            CryptureAttackCategory.Special,
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
        bytes32 randomValue =
            keccak256(abi.encodePacked(block.timestamp, msg.sender));

        _mint(to, id);

        if (cryptureType != CrypturesType.Random) {
            uint256 randomIndex =
                uint256(randomValue) % _crypturesIdByType[cryptureType].length;
            randomValue = _nextRandomValue(randomValue);

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
            CrypturesType randomType = CrypturesType(uint256(randomValue) % 4);

            randomValue = _nextRandomValue(randomValue);
            uint256 randomIndex =
                uint256(randomValue) % _crypturesIdByType[randomType].length;
            randomValue = _nextRandomValue(randomValue);

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
        returns (CryptureAttack memory)
    {
        return _crypturesAttacks[id];
    }

    function getCryptureBaseStats(uint256 id)
        public
        view
        returns (CryptureBaseStats memory)
    {
        return _crypturesBaseStats[id];
    }

    function getStatByLevel(CryptureBaseStats memory baseStats, uint256 level)
        public
        pure
        returns (CryptureStats memory)
    {
        CryptureStats memory stats;

        stats.cryptureType = baseStats.cryptureType;
        stats.healthPoints =
            ((baseStats.healthPoints.max - baseStats.healthPoints.min) *
                (level / 256)) +
            baseStats.healthPoints.max;
        stats.attack =
            ((baseStats.attack.max - baseStats.attack.min) * (level / 256)) +
            baseStats.attack.max;
        stats.defense =
            ((baseStats.defense.max - baseStats.defense.min) * (level / 256)) +
            baseStats.defense.max;
        stats.speed =
            ((baseStats.speed.max - baseStats.speed.min) * (level / 256)) +
            baseStats.speed.max;
        stats.specialAttack =
            ((baseStats.specialAttack.max - baseStats.specialAttack.min) *
                (level / 256)) +
            baseStats.specialAttack.max;
        stats.specialDefense =
            ((baseStats.specialDefense.max - baseStats.specialDefense.min) *
                (level / 256)) +
            baseStats.specialDefense.max;

        return stats;
    }

    function getCryptureCompleteInfo(uint256 id)
        public
        view
        returns (CryptureCompleteInfo memory)
    {
        CryptureInfo memory cryptureInfo = getCryptureInfo(id);

        CryptureAttack[] memory cryptureAttacks =
            new CryptureAttack[](cryptureInfo.attacks.length);
        for (uint256 i = 0; i < cryptureInfo.attacks.length; i++) {
            cryptureAttacks[i] = getCryptureAttack(cryptureInfo.attacks[i]);
        }

        CryptureStats memory cryptureStats =
            getStatByLevel(
                getCryptureBaseStats(cryptureInfo.id),
                cryptureInfo.level
            );

        return
            CryptureCompleteInfo(
                cryptureInfo.id,
                cryptureInfo.level,
                cryptureInfo.xp,
                cryptureInfo.wins,
                cryptureInfo.losses,
                cryptureInfo.fedDate,
                cryptureInfo.washedDate,
                cryptureStats.cryptureType,
                cryptureStats.healthPoints,
                cryptureStats.attack,
                cryptureStats.defense,
                cryptureStats.speed,
                cryptureStats.specialAttack,
                cryptureStats.specialDefense,
                cryptureAttacks
            );
    }

    function getWinnerBattle(uint256 firstCryptureId, uint256 secondCryptureId)
        public
        view
        returns (CryptureBattleResultDetails memory)
    {
        CryptureCompleteInfo memory firstCryptureCompleteInfo =
            getCryptureCompleteInfo(firstCryptureId);
        CryptureCompleteInfo memory secondCryptureCompleteInfo =
            getCryptureCompleteInfo(secondCryptureId);

        // uint256 firstCryptureHealthPoints =
        //     firstCryptureCompleteInfo.healthPoints;
        // uint256 secondCryptureHealthPoints =
        //     secondCryptureCompleteInfo.healthPoints;

        bool fistCryptureAttacksFirst =
            firstCryptureCompleteInfo.speed > secondCryptureCompleteInfo.speed;

        bytes32 randomValue =
            keccak256(abi.encodePacked(block.timestamp, msg.sender));

        CryptureBattleRoundInfo[50] memory roundsInfo;

        for (uint256 round = 0; round < 50; round++) {
            if (
                firstCryptureCompleteInfo.speed ==
                secondCryptureCompleteInfo.speed
            ) {
                fistCryptureAttacksFirst = uint256(randomValue) % 2 == 0
                    ? true
                    : false;
                randomValue = _nextRandomValue(randomValue);
            }

            if (fistCryptureAttacksFirst) {
                uint256 firstRandomAttackId =
                    uint256(randomValue) %
                        firstCryptureCompleteInfo.attacks.length;
                randomValue = _nextRandomValue(randomValue);

                uint256 firstCryptureDamage =
                    (((((2 * firstCryptureCompleteInfo.level) / 5) + 2) *
                        (firstCryptureCompleteInfo.attacks[firstRandomAttackId]
                            .power *
                            (
                                firstCryptureCompleteInfo.attacks[
                                    firstRandomAttackId
                                ]
                                    .category == CryptureAttackCategory.Physical
                                    ? firstCryptureCompleteInfo.attack /
                                        secondCryptureCompleteInfo.defense
                                    : firstCryptureCompleteInfo.specialAttack /
                                        secondCryptureCompleteInfo
                                            .specialDefense
                            ))) / 50) + 2;

                secondCryptureCompleteInfo.healthPoints -= firstCryptureDamage;

                if (secondCryptureCompleteInfo.healthPoints <= 0) {
                    return
                        CryptureBattleResultDetails(
                            ownerOf(firstCryptureId),
                            firstCryptureCompleteInfo,
                            secondCryptureCompleteInfo,
                            roundsInfo
                        );
                }

                uint256 secondRandomAttackId =
                    uint256(randomValue) %
                        secondCryptureCompleteInfo.attacks.length;
                randomValue = _nextRandomValue(randomValue);

                uint256 secondCryptureDamage =
                    (((((2 * secondCryptureCompleteInfo.level) / 5) + 2) *
                        (secondCryptureCompleteInfo.attacks[
                            secondRandomAttackId
                        ]
                            .power *
                            (
                                secondCryptureCompleteInfo.attacks[
                                    secondRandomAttackId
                                ]
                                    .category == CryptureAttackCategory.Physical
                                    ? secondCryptureCompleteInfo.attack /
                                        firstCryptureCompleteInfo.defense
                                    : secondCryptureCompleteInfo.specialAttack /
                                        firstCryptureCompleteInfo.specialDefense
                            ))) / 50) + 2;

                firstCryptureCompleteInfo.healthPoints -= secondCryptureDamage;

                roundsInfo[round] = CryptureBattleRoundInfo(
                    FirstSecond(firstRandomAttackId, secondRandomAttackId),
                    FirstSecond(firstCryptureDamage, secondCryptureDamage),
                    FirstSecond(
                        firstCryptureCompleteInfo.healthPoints,
                        secondCryptureCompleteInfo.healthPoints
                    )
                );

                if (firstCryptureCompleteInfo.healthPoints <= 0) {
                    return
                        CryptureBattleResultDetails(
                            ownerOf(secondCryptureId),
                            firstCryptureCompleteInfo,
                            secondCryptureCompleteInfo,
                            roundsInfo
                        );
                }
            } else {
                uint256 firstRandomAttackId =
                    uint256(randomValue) %
                        firstCryptureCompleteInfo.attacks.length;
                randomValue = _nextRandomValue(randomValue);

                uint256 firstCryptureDamage =
                    (((((2 * secondCryptureCompleteInfo.level) / 5) + 2) *
                        (secondCryptureCompleteInfo.attacks[firstRandomAttackId]
                            .power *
                            (
                                secondCryptureCompleteInfo.attacks[
                                    firstRandomAttackId
                                ]
                                    .category == CryptureAttackCategory.Physical
                                    ? secondCryptureCompleteInfo.attack /
                                        firstCryptureCompleteInfo.defense
                                    : secondCryptureCompleteInfo.specialAttack /
                                        firstCryptureCompleteInfo.specialDefense
                            ))) / 50) + 2;

                firstCryptureCompleteInfo.healthPoints -= firstCryptureDamage;

                if (firstCryptureCompleteInfo.healthPoints <= 0) {
                    return
                        CryptureBattleResultDetails(
                            ownerOf(secondCryptureId),
                            firstCryptureCompleteInfo,
                            secondCryptureCompleteInfo,
                            roundsInfo
                        );
                }

                uint256 secondRandomAttackId =
                    uint256(randomValue) %
                        firstCryptureCompleteInfo.attacks.length;
                randomValue = _nextRandomValue(randomValue);

                uint256 secondCryptureDamage =
                    (((((2 * firstCryptureCompleteInfo.level) / 5) + 2) *
                        (firstCryptureCompleteInfo.attacks[secondRandomAttackId]
                            .power *
                            (
                                firstCryptureCompleteInfo.attacks[
                                    secondRandomAttackId
                                ]
                                    .category == CryptureAttackCategory.Physical
                                    ? firstCryptureCompleteInfo.attack /
                                        secondCryptureCompleteInfo.defense
                                    : firstCryptureCompleteInfo.specialAttack /
                                        secondCryptureCompleteInfo
                                            .specialDefense
                            ))) / 50) + 2;

                secondCryptureCompleteInfo.healthPoints -= secondCryptureDamage;

                roundsInfo[round] = CryptureBattleRoundInfo(
                    FirstSecond(firstRandomAttackId, secondRandomAttackId),
                    FirstSecond(firstCryptureDamage, secondCryptureDamage),
                    FirstSecond(
                        firstCryptureCompleteInfo.healthPoints,
                        secondCryptureCompleteInfo.healthPoints
                    )
                );

                if (secondCryptureCompleteInfo.healthPoints <= 0) {
                    return
                        CryptureBattleResultDetails(
                            ownerOf(firstCryptureId),
                            firstCryptureCompleteInfo,
                            secondCryptureCompleteInfo,
                            roundsInfo
                        );
                }
            }
        }

        return
            CryptureBattleResultDetails(
                address(0),
                firstCryptureCompleteInfo,
                secondCryptureCompleteInfo,
                roundsInfo
            );
    }

    function _nextRandomValue(bytes32 value) private pure returns (bytes32) {
        return keccak256(abi.encode(value));
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
