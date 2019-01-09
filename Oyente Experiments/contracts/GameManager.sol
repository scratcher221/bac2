pragma experimental ABIEncoderV2;
pragma solidity ^0.5.0;
import "./BettingFactory.sol";
import "./SafeMath.sol";
import "./SafeMath32.sol";

/// @title Used for updating game status, creating new games and distributing shares
/// @author David Mitterlehner
/// @notice Games will be created through this contract
/// @notice Only the creators of the contract and admins should be able to call writing functions in this contract
/// @notice View functions should be callable by regular users too
contract GameManager is BettingFactory {
  using SafeMath for uint;
  using SafeMath32 for uint32;
  event GameStateChanged(GameState state, uint gameId);
  event NewGame(uint gameId, Game game);
  Game[] public mGames;
  uint32 public mActiveGames = 0;

  struct Game {
    string homeTeam;
    string awayTeam;
    string time;
    string location;
    GameResult result;
    GameState state;
    GameType gameType;
  }

  enum GameType {
    SOCCER,
    BASKETBALL,
    VOLLEYBALL,
    TENNIS
  }

  enum GameState {
    PENDING,
    PLAYING,
    FINISHED,
    CANCELLED
  }

  /// @notice Creates a new game and stores it in the blockchain
  function createNewGame(GameType _gameType, string calldata _home, string calldata _away, string calldata _time, string calldata _location) external onlyOwner {
    Game memory createGame = Game(_home, _away, _time, _location, GameResult.UNKNOWN, GameState.PENDING, _gameType);
    uint gameId = mGames.push(createGame);
    emit NewGame(gameId, createGame);
    mActiveGames.add(1);
  }

  /// @notice Creates a new game and stores it in the blockchain
  function createTestGames() external onlyOwner {
    /**
    Game memory createGame = Game("FC Barcelona", "Real Madrid", "1.8.2018, 20:00 CET", "Santiago Bernabeo, Madrid", GameResult.UNKNOWN, GameState.PENDING, GameType.SOCCER);
    uint gameId = mGames.push(createGame);
    emit NewGame(gameId, createGame);
    mActiveGames++;

    Game memory createGame2 = Game("FC Chelsea", "Manchester City", "9.8.2018, 19:20 CET", "Stamford Bridge, London", GameResult.UNKNOWN, GameState.PENDING, GameType.SOCCER);
    uint gameId2 = mGames.push(createGame2);
    emit NewGame(gameId2, createGame2);
    mActiveGames++;
    **/

    Game memory createGame3 = Game("Sweden", "Switzerland", "3.7.2018, 16:00 CET", "Sankt-Petersburg-Stadium, Sankt Petersburg", GameResult.UNKNOWN, GameState.PENDING, GameType.SOCCER);
    uint gameId3 = mGames.push(createGame3);
    emit NewGame(gameId3, createGame3);
    mActiveGames = mActiveGames.add(1);

    Game memory createGame4 = Game("Columbia", "England", "3.7.2018, 20:00 CET", "Spartak-Stadium, Moscow", GameResult.UNKNOWN, GameState.PENDING, GameType.SOCCER);
    uint gameId4 = mGames.push(createGame4);
    emit NewGame(gameId4, createGame4);
    mActiveGames = mActiveGames.add(1);

    Game memory createGame5 = Game("Uruguay", "France", "6.7.2018, 16:00 CET", "Nischni-Nowgorod-Stadium, Nischni-Nowgorod", GameResult.UNKNOWN, GameState.PENDING, GameType.SOCCER);
    uint gameId5 = mGames.push(createGame5);
    emit NewGame(gameId5, createGame5);
    mActiveGames = mActiveGames.add(1);

    Game memory createGame6 = Game("Brasil", "Belgium", "6.7.2018, 20:00 CET", "Kasan-Arena, Kasan", GameResult.UNKNOWN, GameState.PENDING, GameType.SOCCER);
    uint gameId6 = mGames.push(createGame6);
    emit NewGame(gameId6, createGame6);
    mActiveGames = mActiveGames.add(1);
  }

  /// @notice Updates the game state of a specific game
  function updateGameState(GameState _state, uint _gameId) public onlyOwner {
    mGames[_gameId].state = _state;
    if (_state == GameState.CANCELLED || _state == GameState.FINISHED || _state == GameState.PLAYING) {
      mActiveGames = mActiveGames.sub(1);
    }
    emit GameStateChanged(_state, _gameId);
  }

  /// @notice Used for updating the game state, e.g. when a game finished. If the game was cancelled, set the GameResult to UNKNOWN
  function setGameResult(uint _gameId, GameResult _result) external onlyOwner {
    updateGameState(GameState.FINISHED, _gameId);
    mGames[_gameId].result = _result;
    emit GameStateChanged(GameState.FINISHED, _gameId);
  }

  /// @notice Returns the game details for a specific game
  function getGame(uint _gameId) external view returns (uint id, string memory homeTeam, string memory awayTeam, string memory time, string memory location, GameResult result, GameState state, GameType gameType) {
    id = _gameId;
    homeTeam = mGames[_gameId].homeTeam;
    awayTeam = mGames[_gameId].awayTeam;
    time = mGames[_gameId].time;
    location = mGames[_gameId].location;
    result = mGames[_gameId].result;
    state = mGames[_gameId].state;
    gameType = mGames[_gameId].gameType;
  }

  // @notice Returns the games which are currently open for bets
  function getActiveGameIds() external view returns (uint[] memory games) {
    //count active games
    /* uint myActiveGames = 0;
    uint i;
    for (i = 0; i < mGames.length; i++) {
      if (mGames[i].state == GameState.PENDING) {
        myActiveGames++;
      }
    }*/

    uint[] memory games = new uint[](mActiveGames);
    uint j = 0;
    for (uint i = 0; i < mGames.length; i = i.add(1)) {
      if (mGames[i].state == GameState.PENDING) {
        games[j] = i;
        j = j.add(1);
      }
    }
    return games;
  }

  function getmActiveGames() external view returns (uint32) {
    return mActiveGames;
  }

}
