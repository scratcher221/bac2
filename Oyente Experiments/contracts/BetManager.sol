pragma solidity ^0.4.24;
import "./BettingFactory.sol";
import "./GameManager.sol";

/// @title A contract which implements the end user interface
/// @notice Users should be able to call functions in this contract to manage their bets.
contract BetManager is GameManager {
  event Withdrawal(address receiver, uint amount);
  /// @notice Users can call this function to redeem their shares if they won a bet
  function withdrawFundsForBet(uint _betId) public returns (bool success) {
    //require that the user that calls function has created that bet and that the bet has not been withdrawn before
    require(msg.sender == mBets[_betId].creator && mBets[_betId].betStatus == BetStatus.VALID);
    //require that the user has actually won the bet.
    require(mBets[_betId].wageredResult == mGames[mBets[_betId].gameId].result);
    address receiver = mBets[_betId].creator;

    //compute total sum of shares for that bet
    uint totalAmountHome = 0;
    uint totalAmountDraw = 0;
    uint totalAmountAway = 0;

    for (uint i=0; i<mBets.length; i++) {
      if (mBets[i].gameId == mBets[_betId].gameId){
        if (mBets[i].wageredResult == GameResult.HOME){
          totalAmountHome += mBets[i].amount;
        } else if (mBets[i].wageredResult == GameResult.DRAW){
          totalAmountDraw += mBets[i].amount;
        } else if (mBets[i].wageredResult == GameResult.AWAY){
          totalAmountAway += mBets[i].amount;
        }
      }
    }

    uint totalAmount = totalAmountHome + totalAmountDraw + totalAmountAway;
    uint sumOnMyOption;
    if (mBets[_betId].wageredResult == GameResult.HOME) {
      sumOnMyOption = totalAmountHome;
    }
    else if (mBets[_betId].wageredResult == GameResult.DRAW) {
      sumOnMyOption = totalAmountDraw;
    }
    else if (mBets[_betId].wageredResult == GameResult.AWAY) {
      sumOnMyOption = totalAmountAway;
    }
    uint sumOnLostOptions = totalAmount - sumOnMyOption;

    mBets[_betId].betStatus = BetStatus.DONE;

    uint payoutFactor = (mBets[_betId].amount * 1000) / sumOnMyOption;
    //uint remainder = (mBets[_betId].amount * 1000) % sumOnMyOption;

    uint share = (payoutFactor * sumOnLostOptions) / 1000;
    //uint shareRemainder = (payoutFactor * sumOnLostOptions) % 1000;

    uint payout = mBets[_betId].amount + share;
    if (!receiver.send(payout)) {
      throw;
    }
    emit Withdrawal(receiver, payout);
    return true;
  }

}
