// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract OracleClient is ChainlinkClient {

    using Chainlink for Chainlink.Request;

    address internal oracle;
    bytes32 internal jobId;
    uint256 internal fee;

    mapping(bytes32 => uint256) requestIdToMatch;

    constructor() {
        setPublicChainlinkToken();
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId  = "d5270d1c311941d0b08bead21fea7747";
        fee    = 0.1 * 10 ** 18;
    }

    function requestMatchStatus(string memory _url, uint256 _matchId, bytes4 _selector) public returns (bytes32 requestId)
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), _selector);

        request.add("get", _url);
        // Ex url: "https://api.pandascore.co/matches/595477?token=4AUFMvQbjLwRnnuM5NLQqVwj8WPu-wQgNssRZjpV9WDDjnvNI68"
        request.add("path", "winner.id");
        request.addInt("times", 1);

        requestId = sendChainlinkRequestTo(oracle, request, fee);

        requestIdToMatch[requestId] = _matchId;
    }
}
