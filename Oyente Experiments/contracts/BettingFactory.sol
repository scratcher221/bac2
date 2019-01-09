pragma experimental ABIEncoderV2;
pragma solidity ^0.5.0;
import "./Ownable.sol";

/// @title A contract, which implements the core functionality of the betting webapp
/// @author David Mitterlehner
/// @notice Bets will be created through this contract
contract BettingFactory is Ownable {
  event NewBet(uint betId, Bet bet);
  Bet[] public mBets;

  enum GameResult {
    UNKNOWN,
    HOME,
    AWAY,
    DRAW
  }

  enum BetStatus {
    VALID,
    INVALID,
    DONE
  }

  struct Bet {
    uint gameId;
    uint amount;
    address payable creator;
    GameResult wageredResult;
    BetStatus betStatus;
  }


  /// @notice Creates a new bet for a specific user. Anyone can create bets from their account (address) for their account
  function createNewBet(uint _gameId, GameResult _wageredResult) external payable {
  //function createNewBet(address _creator, uint _gameId, uint _amount, GameResult _wageredResult) external payable {
    require(msg.value != 0);
    //require(msg.sender == _creator && msg.value == _amount);
    Bet memory placeBet = Bet(_gameId, msg.value, msg.sender, _wageredResult, BetStatus.VALID);
    uint betId = mBets.push(placeBet);
    emit NewBet(betId, placeBet);
  }

  /// @notice Invalidates a specific bet (for example when the user withdraws funds, or if a game was cancelled)
  function invalidateBet(uint _betId) external onlyOwner {
    mBets[_betId].betStatus = BetStatus.INVALID;
  }

  /// @notice Gets all bets that have been placed by a specific address
  function getBetsByCreator(address _creator) external view returns(uint[] memory bets) {
    //count how many bet its there are
    uint j = 0;
    for (uint i=0; i < mBets.length; i++) {
      if (mBets[i].creator == _creator) {
        j++;
      }
    }

    //place bet its there
    uint[] memory bets = new uint[](j);
    j = 0;
    for (uint i=0; i < mBets.length; i++) {
      if (mBets[i].creator == _creator) {
        bets[j] = i;
        j++;
      }
    }
    return bets;
    //uint[] memory placedBets = new uint[](mBets.length);
    //uint j=0;
    //for (uint i=0; i < mBets.length; i++) {
    //  if (mBets[i].creator == _creator) {
    //    placedBets[j] = i;
    //    j++;
    //  }
    //}
    //return placedBets;
  }

  /// @notice Returns ids for bets that were placed on a game
  function getBetsForGameId(uint _gameId) public view returns(uint[] memory bets) {
    //count how many bet its there are
    uint j = 0;
    for (uint i=0; i < mBets.length; i++) {
      if (mBets[i].gameId == _gameId) {
        j++;
      }
    }

    //place bet its there
    uint[] memory bets = new uint[](j);
    j = 0;
    for (uint i=0; i < mBets.length; i++) {
      if (mBets[i].gameId == _gameId) {
        bets[j] = i;
        j++;
      }
    }
    return bets;
    //uint[] memory placedBets = new uint[](mBets.length);
    //uint j=0;
    //for (uint i=0; i < mBets.length; i++) {
    //  if (mBets[i].gameId == _gameId) {
    //    placedBets[j] = i;
    //    j++;
    //  }
    //}
    //return placedBets;

  }

  /// @notice Returns the bet details for a specific bet
  function getBet(uint _betId) public view returns (uint id, uint gameId, uint amount, address creator, GameResult wageredResult, BetStatus betStatus) {
    //uint gameId;uint amount;address creator;GameResult wageredResult;BetStatus betStatus;

    id = _betId;
    gameId = mBets[_betId].gameId;
    amount = mBets[_betId].amount;
    creator = mBets[_betId].creator;
    wageredResult = mBets[_betId].wageredResult;
    betStatus = mBets[_betId].betStatus;
  }

  /// @notice Returns all data of a certain bet
  function getBetData(uint _betId) external view returns (uint, uint, address, GameResult, BetStatus) {
    return (mBets[_betId].gameId, mBets[_betId].amount, mBets[_betId].creator, mBets[_betId].wageredResult, mBets[_betId].betStatus);
  }
}
