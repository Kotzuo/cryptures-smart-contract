// SPDX-License-Identifier: MIT

import "./openzeppelin-contracts/contracts/utils/Context.sol";

import "./cherish.sol";
import "./cryptures.sol";

pragma solidity ^0.8.0;

contract CrypturesManager is Context {
    Cherish public cherish;
    Cryptures public cryptures;

    struct BattleRequest {
        uint256 cryptureId;
        uint256 cherishAmount;
        bool isValid;
    }

    mapping(address => mapping(address => BattleRequest))
        private _battlesRequest;

    uint8 private _initialSaleCrypturesSold;

    uint256 private _lastBattleId;

    address private _owner;

    constructor(string memory baseTokenURI) {
        cherish = new Cherish();
        cryptures = new Cryptures(baseTokenURI);

        _owner = _msgSender();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function buyCrypture(Cryptures.CrypturesType cryptureType) public payable {
        require(
            _initialSaleCrypturesSold < 10,
            "CrypturesManager: Initial sale with Ether sold out"
        );
        require(
            msg.value >= 0.1 ether,
            "CrypturesManager: Correct price is 0.1 Ether"
        );

        cryptures.mint(_msgSender(), cryptureType);
        _initialSaleCrypturesSold++;
    }

    function buyCryptureWithToken(Cryptures.CrypturesType cryptureType) public {
        require(
            _initialSaleCrypturesSold < 100,
            "CrypturesManager: Initial sale with Cherish sold out"
        );

        cherish.burnFrom(_msgSender(), 30000);

        cryptures.mint(_msgSender(), cryptureType);
        _initialSaleCrypturesSold++;
    }

    function feedCrypture(uint256 id) public {
        uint256 lastFedDate = cryptures.feedCreatureFromId(id);

        uint256 cherisholReward =
            ((block.timestamp - lastFedDate) * (500)) / 1 days;

        cherish.mint(_msgSender(), cherisholReward);
    }

    function washCrypture(uint256 id) public {
        uint256 lastWashedDate = cryptures.washCreatureFromId(id);

        uint256 cherisholReward =
            ((block.timestamp - lastWashedDate) * (500)) / 1 days;

        cherish.mint(_msgSender(), cherisholReward);
    }

    function refundCrypture(uint256 id) public {
        require(
            cryptures.ownerOf(id) == _msgSender(),
            "CrypturesManager: Only Crypture owner can refund this for Cherish"
        );

        cryptures.forceBurn(id);
        cherish.mint(_msgSender(), 15000);
    }

    function TEST_giveCherish() public {
        cherish.mint(_msgSender(), 30000);
    }

    function requestBattle(
        uint256 ownCryptureId,
        address opponentAddress,
        uint256 cherishAmount
    ) public {
        require(
            cryptures.balanceOf(opponentAddress) > 0,
            "CrypturesManager: opponent does not have any crypture"
        );
        require(
            cryptures.ownerOf(ownCryptureId) == _msgSender(),
            "CrypturesManager: you do not own the crypture especified"
        );
        require(
            opponentAddress != _msgSender(),
            "CrypturesManager: you cant battle your own crypture"
        );

        cherish.forcedTransfer(_msgSender(), address(this), cherishAmount);

        _battlesRequest[opponentAddress][_msgSender()] = BattleRequest(
            ownCryptureId,
            cherishAmount,
            true
        );

        emit BattleRequested(
            opponentAddress,
            _msgSender(),
            ownCryptureId,
            cherishAmount
        );
    }

    function battleResult(address winner, address loser) public onlyOwner {
        BattleRequest memory winnerBattleRequest =
            _battlesRequest[winner][loser];
        BattleRequest memory loserBattleRequest =
            _battlesRequest[loser][winner];

        require(
            winnerBattleRequest.isValid && loserBattleRequest.isValid,
            "CrypturesManager: Invalid battle."
        );

        cherish.transfer(
            winner,
            winnerBattleRequest.cherishAmount + loserBattleRequest.cherishAmount
        );

        delete _battlesRequest[winner][loser];
        delete _battlesRequest[loser][winner];

        emit BattleResult(
            winner,
            loser,
            _lastBattleId,
            winnerBattleRequest.cherishAmount + loserBattleRequest.cherishAmount
        );

        _lastBattleId++;
    }

    event BattleRequested(
        address indexed requested,
        address requester,
        uint256 cryptureId,
        uint256 cherishAmount
    );
    event BattleResult(
        address indexed winner,
        address indexed loser,
        uint256 battleId,
        uint256 cherishAmount
    );
}
