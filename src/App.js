import React from 'react';
import Home from "./pages/Home";
import Game from './pages/Game';
import Account from "./components/Account/Account";
import Logo from "./images/Logo.jpeg";
import { Link } from "react-router-dom";
import { useState } from 'react';
import { Routes, Route } from "react-router-dom";
import { Layout } from "antd";
import './App.css';

const { Content, Header } = Layout;

const App = () => {

  const [game, setGame] = useState();

  return (
    <>
      <Layout>
        <Header className="header">
          <Link to="/">
            <img src={Logo} alt="Logo" className="logo"></img>
          </Link>
          <div>
            <Account />
          </div>
        </Header>
        <Layout>
          <Content className="contentWindow">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/game" element={<Game setGame={setGame}/>} />
          </Routes>
          </Content>
        </Layout>
      </Layout>
    </>
  );
}


export default App;
