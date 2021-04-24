// SPDX-License-Identifier: MIT

import "./openzeppelin-contracts/contracts/utils/Context.sol";

import "./cherishol.sol";
import "./cryptures.sol";

pragma solidity ^0.8.0;

contract CrypturesManager is Context {
    Cherishol public cherishol;
    Cryptures public cryptures;

    struct BattleRequest {
        uint256 cryptureId;
        uint256 cherisholAmount;
        bool isValid;
    }

    mapping(address => mapping(address => BattleRequest))
        private _battlesRequest;

    constructor(string memory baseTokenURI) {
        cherishol = new Cherishol();
        cryptures = new Cryptures(baseTokenURI);
    }

    function buyCrypture(Cryptures.CrypturesType cryptureType) public payable {
        cryptures.mint(_msgSender(), cryptureType);
    }

    function buyCryptureWithToken(Cryptures.CrypturesType cryptureType) public {
        cherishol.burnFrom(_msgSender(), 30 * (10**18));

        cryptures.mint(_msgSender(), cryptureType);
    }

    function feedCrypture(uint256 id) public {
        uint256 lastFedDate = cryptures.feedCreatureFromId(id);

        if (block.timestamp - lastFedDate >= 1 days) {
            cherishol.mint(_msgSender(), 1 * (10**18));
        } else {
            uint256 cherisholReward =
                ((block.timestamp - lastFedDate) * (1 * (10**18))) / 1 days;
            cherishol.mint(_msgSender(), cherisholReward);
        }
    }

    function washCrypture(uint256 id) public {
        uint256 lastWashedDate = cryptures.washCreatureFromId(id);

        if (block.timestamp - lastWashedDate > 1 days) {
            cherishol.mint(_msgSender(), 1 * (10**18));
        } else {
            uint256 cherisholReward =
                ((block.timestamp - lastWashedDate) * (1 * (10**18))) / 1 days;
            cherishol.mint(_msgSender(), cherisholReward);
        }
    }

    function requestBattle(
        uint256 ownCryptureId,
        uint256 opponentCryptureId,
        uint256 cherisholAmount
    ) public returns (Cryptures.CryptureBattleResultDetails memory) {
        address opponentAddress = cryptures.ownerOf(opponentCryptureId);

        require(
            cryptures.ownerOf(ownCryptureId) == _msgSender(),
            "ERC721: you do not own the crypture especified"
        );
        require(
            opponentAddress != _msgSender(),
            "CrypturesManager: you cant battle your own crypture"
        );
        require(
            cherisholAmount <= cherishol.balanceOf(_msgSender()),
            "ERC20: bid amount exceeds balance"
        );

        BattleRequest memory battleRequest =
            _battlesRequest[_msgSender()][opponentAddress];
        if (battleRequest.isValid) {
            Cryptures.CryptureBattleResultDetails memory battleResultDetails =
                cryptures.getWinnerBattle(ownCryptureId, opponentCryptureId);
            address winnerAddress = battleResultDetails.winnerAddress;

            if (winnerAddress == address(0)) {
                cherishol.transfer(
                    opponentAddress,
                    battleRequest.cherisholAmount
                );
            } else {
                cherishol.transfer(
                    winnerAddress,
                    winnerAddress == _msgSender()
                        ? battleRequest.cherisholAmount
                        : cherisholAmount
                );
            }

            return battleResultDetails;
        } else {
            _battlesRequest[opponentAddress][_msgSender()] = BattleRequest(
                ownCryptureId,
                cherisholAmount,
                true
            );

            cherishol.forcedTransfer(
                _msgSender(),
                address(this),
                cherisholAmount
            );

            Cryptures.CryptureAttack[] memory emptyAttacks =
                new Cryptures.CryptureAttack[](0);

            Cryptures.CryptureBattleRoundInfo[100] memory emptyRoundsInfo;

            return
                Cryptures.CryptureBattleResultDetails(
                    address(0),
                    Cryptures.CryptureCompleteInfo(
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        Cryptures.CrypturesType.Grass,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        emptyAttacks
                    ),
                    Cryptures.CryptureCompleteInfo(
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        Cryptures.CrypturesType.Grass,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        emptyAttacks
                    ),
                    emptyRoundsInfo
                );
        }
    }
}
