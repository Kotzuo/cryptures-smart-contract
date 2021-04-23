// SPDX-License-Identifier: MIT

import "./openzeppelin-contracts/contracts/utils/Context.sol";

import "./cherishol.sol";
import "./cryptures.sol";

pragma solidity ^0.8.0;

contract CrypturesManager is Context {
    Cherishol public cherishol;
    Cryptures public cryptures;

    constructor() {
        cherishol = new Cherishol();
        cryptures = new Cryptures("http://localhost:8000/crypture/");
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

    function battle(uint256 ownCryptureId, uint256 enemyCryptureId) public {
        // Cryptures.CryptureStats memory ownCryptureStats =
        //     cryptures.getCryptureStatus(ownCryptureId);
        // Cryptures.CryptureStats memory enemyCryptureStats =
        //     cryptures.getCryptureStatus(enemyCryptureId);
        // bool gameEnded = false;
        // while (!gameEnded) {
        //     if (ownCryptureStats.speed > enemyCryptureStats.speed) {
        //     } else if (
        //         ownCryptureStats.speed == enemyCryptureStats.speed
        //     ) {
        //     } else {
        //     }
        // }
    }
}
