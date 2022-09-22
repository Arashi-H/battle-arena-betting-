import React from "react";
import { useLocation } from "react-router";
import { executePlaceBet, executeCheckAndDistributeRewards, executeGetMatchIdsFromGameIds } from "../helpers/contract.js";
import { Tabs } from "antd";
import "./Game.css";

const { TabPane } = Tabs;

const Game = ({ setGame }) => {
  const { state: gameDetails } = useLocation();

  const [ matches, setMatches ] = React.useState([]);
  const [ finishedMatches, setFinishedMatches ] = React.useState([]);

  async function getMatchesDetails(matchIds) {
    return matchIds.map((matchId) => {
      const api = "https://api.pandascore.co/matches/" + matchId + "?token=4AUFMvQbjLwRnnuM5NLQqVwj8WPu-wQgNssRZjpV9WDDjnvNI68";
      const matchDetails = fetch(api).then((response) => response.json());
      return matchDetails;
    })
  }

  React.useEffect(() => {
    fetch(gameDetails.matchesApiUrl).then((response) => response.json()).then((matches) => setMatches(matches));
    executeGetMatchIdsFromGameIds(gameDetails.id)
      .then((matchIds) => getMatchesDetails(matchIds))
      .then((promises) => {Promise.all(promises).then((finishedMatches) => setFinishedMatches(finishedMatches))});
  }, []);

  return (
    <>
      <div className="gameContent">
        <div className="topBan">
          <img
            src={gameDetails.image}
            alt="gamecover"
            className="gameCover"
          ></img>
          <div className="Deets">
            <div className="title">{gameDetails.title}</div>
            <div>
              {matches && matches.length} Live Matches
            </div>
          </div>
        </div>
        <div className="topBan">
          <div
            className="openButton"
            onClick={() =>
              window.open(
                `${gameDetails.website}`
              )
            }
          >
            Website
          </div>
        </div>
        <Tabs defaultActiveKey="1" centered>
          <TabPane tab="LIVE MATCHES" key="1">
            <div className="tableHeader">
              <div className="numberHeader">Match Id</div>
              <div className="titleHeader">MATCH</div>
              <div className="titleHeader">Team A</div>
              <div className="titleHeader">Team B</div>
            </div>
            {matches.filter((match, i) => match.opponents.length == 2).map((match) => {
                return (
                  <>
                    <div className="tableContent">
                      <div className="numberHeader">{match.id}</div>
                      <div className="titleHeader" style={{ color: "rgb(205, 203, 203)" }}>
                        {match.name}
                      </div>
                      <div className="titleHeader">
                        <div className="rowContent">
                          {match.opponents[0].opponent.name}
                        </div>
                        <div className="betButton" onClick = {() => executePlaceBet(gameDetails.id, match.id, match.opponents[0].opponent.id, match.opponents[1].opponent.id, match.opponents[0].opponent.id)}>
                          Bet
                        </div>
                      </div>
                      <div className="titleHeader">
                        <div className="rowContent">
                          {match.opponents[1].opponent.name}
                        </div>
                        <div className="betButton" onClick={() => executePlaceBet(gameDetails.id, match.id, match.opponents[0].opponent.id, match.opponents[1].opponent.id, match.opponents[1].opponent.id)}>
                          Bet
                        </div>
                      </div>
                    </div>
                  </>
                );
              })
            }
          </TabPane>
          <TabPane tab="DISTRIBUTE REWARDS" key="2">
            <div className="tableHeader">
              <div className="numberHeader">Match Id</div>
              <div className="titleHeader2">MATCH</div>
              <div className="titleHeader2">Team A</div>
              <div className="titleHeader2">Team B</div>
              <div className="rewardHeader"></div>
            </div>
            {finishedMatches.filter((match, i) => match.opponents.length == 2).map((match) => {
                return (
                  <>
                    <div className="tableContent">
                      <div className="numberHeader">{match.id}</div>
                      <div className="titleHeader2" style={{ color: "rgb(205, 203, 203)" }}> 
                        {match.name}
                      </div>
                      <div className="titleHeader2">
                        {match.opponents[0].opponent.name}
                      </div>
                      <div className="titleHeader2">
                        {match.opponents[1].opponent.name}
                      </div>
                      <div className="rewardHeader">
                        <div className="distributeButton" onClick = {() => executeCheckAndDistributeRewards(match.id)}>
                          Rewards
                        </div>
                      </div>
                    </div>
                  </>
                );
              })
            }
          </TabPane>
        </Tabs>
      </div>
    </>
  );
};

export default Game;
