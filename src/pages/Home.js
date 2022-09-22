import React from "react";
import { Link } from "react-router-dom";
import { library } from "../helpers/games";
import "./Home.css";

const Home = () => {
  return (
    <>
      <h1 className="featuredTitle">Let the battle begin !!</h1>
      <div className="games">
        {library.map((e) => (
          <Link to="/game" state={e} className="gameSelection">
            <img
              src={e.image}
              alt="bull"
              style={{ width: "150px", marginBottom: "10px" }}
            ></img>
            <p>{e.title}</p>
          </Link>
        ))}
      </div>
    </>
  );
};

export default Home;
