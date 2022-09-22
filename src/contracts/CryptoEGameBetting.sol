// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./strings.sol";
import "./Satta.sol";
import "./OracleClient.sol";

contract CryptoEGameBetting is Ownable, OracleClient {

    using SafeMath for uint256;

    event BetPlaced(address indexed _from, uint matchId, uint256 teamToWin);
    event Transfer(address indexed _to, uint reward);

    uint256 public bettingAmount;
    string private apiToken;

    struct Match {
        uint256 gameId;
        uint256 matchId;

        uint256 teamA;
        uint256 teamB;

        uint256 totalPayoutA;
        uint256 totalPayoutB;

        address[] betsOnA;
        address[] betsOnB;

        string apiUrl;

        uint256 winner;
        bool ended;
    }

    mapping(uint => Match) private idToMatch;
    mapping(uint => uint[]) private gameIdToMatchIds;

    ERC20 public satta;

    constructor(address _sattaTokenAddress, string memory _apiToken) OracleClient() {
        satta         = Satta(_sattaTokenAddress);
        apiToken      = _apiToken;

        bettingAmount = 10 * 10**uint(satta.decimals());
    }

    modifier validatePlaceBets(uint256 _matchId) {
        // TODO: check if match is not_started 
        string memory errorMessage = concatStrings("Bet Price is ", Strings.toString(bettingAmount.div(satta.decimals())), "!! Please allow this amount to be spent by contract address", "");
        require(satta.allowance(msg.sender, address(this)) >= bettingAmount, errorMessage);
        _;
    }

    function placeBet(uint _gameId, uint _matchId, uint _teamAId, uint _teamBId, uint _teamToWinId) public {
        satta.transferFrom(msg.sender, address(this), bettingAmount);

        if(idToMatch[_matchId].totalPayoutA.add(idToMatch[_matchId].totalPayoutB) == 0)
        {
            string memory matchUrl = concatStrings("https://api.pandascore.co/matches/", Strings.toString(_matchId), "?token=", apiToken);
            Match memory newMatch = Match({gameId:_gameId, matchId:_matchId, teamA:_teamAId, teamB:_teamBId, totalPayoutA:0, totalPayoutB:0, betsOnA: new address[](0), betsOnB: new address[](0), apiUrl:matchUrl, winner:0, ended:false});
            idToMatch[_matchId] = newMatch;
            gameIdToMatchIds[_gameId].push(newMatch.matchId);
        }

        if(_teamToWinId == _teamAId)
        {
            idToMatch[_matchId].totalPayoutA = idToMatch[_matchId].totalPayoutA.add(bettingAmount);
            idToMatch[_matchId].betsOnA.push(msg.sender);
        }
        else
        {
            require(_teamToWinId == _teamBId, "Team to win should be either teamA or teamB");
            idToMatch[_matchId].totalPayoutB = idToMatch[_matchId].totalPayoutB.add(bettingAmount);
            idToMatch[_matchId].betsOnB.push(msg.sender);
        }

        emit BetPlaced(msg.sender, _matchId, _teamToWinId);
    }

    function checkAndDistributeRewards(uint256 _matchId) public onlyOwner {
        Match storage _match = idToMatch[_matchId];
        require(!_match.ended, "match has already ended");
        requestMatchStatus(_match.apiUrl, _matchId, this.distributeRewards.selector);
    }

    function distributeRewards(bytes32 _requestId, uint256 _result) public recordChainlinkFulfillment(_requestId){
        uint256 matchId = requestIdToMatch[_requestId];
        Match storage completedMatch = idToMatch[matchId];
        completedMatch.ended = true;
        completedMatch.winner = _result;

        uint totalRewards = completedMatch.totalPayoutA.add(completedMatch.totalPayoutB);

        address[] memory winners;
        uint reward;
        if(_result == completedMatch.teamA) {
            reward  = totalRewards.div(completedMatch.betsOnA.length);
            winners = completedMatch.betsOnA;
        }
        else if(_result == completedMatch.teamB) {
            reward  = totalRewards.div(completedMatch.betsOnB.length);
            winners = completedMatch.betsOnB;
        }

        for(uint i = 0; i < winners.length; i++)
        {
            satta.transfer(winners[i], reward);
        }

        uint[] storage onGoingMatchesIdsForGame = gameIdToMatchIds[completedMatch.gameId];
        uint index;
        for(uint i = 0; i < onGoingMatchesIdsForGame.length; i++)
        {
            if(onGoingMatchesIdsForGame[i] == matchId)
            {
                index = i;
            }
        }
        onGoingMatchesIdsForGame[index] = onGoingMatchesIdsForGame[onGoingMatchesIdsForGame.length - 1];
        onGoingMatchesIdsForGame.pop();

        delete idToMatch[matchId];
    }

    function concatStrings(string memory _string1, string memory _string2, string memory _string3, string memory _string4) private pure returns (string memory) {
        return string(abi.encodePacked(_string1, _string2, _string3, _string4));
    }

    function getMatch(uint _matchId) public view returns (Match memory) {
        return idToMatch[_matchId];
    }

    function getMatchIdsForGame(uint _gameId) public view returns (uint[] memory) {
        return gameIdToMatchIds[_gameId];
    }

    function setApiToken(string memory _apiToken) public onlyOwner {
        apiToken = _apiToken;
    }

    function setOracleSpecifications(address _oracle, bytes32 _jobId, uint _fee) public onlyOwner {
        oracle = _oracle;
        jobId  = _jobId;
        fee    = _fee;
    }
}