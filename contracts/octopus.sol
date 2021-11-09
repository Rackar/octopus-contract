pragma solidity ^0.8.3;

// SPDX-License-Identifier: MIT

contract OCGT {
    struct Player {
        address userAddress;
        uint256 matchId;
        string color;
        string lucky;
    }
    struct Match {
        string startTime;
        uint256 playerLimit;
        uint256 matchId;
    }

    Match[] public matches;
    Match currentMatch;

    mapping(uint256 => Player[]) matchIdToPlayers;
    mapping(uint256 => Player) matchIdToWinner;

    modifier ownAble() {
        require(msg.sender == address(0));
        _;
    }

    function startNewMatch(string memory _startTime, uint256 _playerLimit)
        public
        ownAble
    {
        uint256 index = matches.length;
        currentMatch = Match(_startTime, _playerLimit, index);
        matches.push(currentMatch);
    }

    function getCurrentMatch() public view returns (Match memory) {
        return currentMatch;
    }

    function getMatchPlayers(uint256 _matchId)
        public
        view
        returns (Player[] memory)
    {
        return matchIdToPlayers[_matchId];
    }

    function joinMatch(
        uint256 _matchId,
        string memory _color,
        string memory _lucky
    ) public payable {
        address _ad = msg.sender;
        Player[] storage players = matchIdToPlayers[_matchId];
        players.push(Player(_ad, _matchId, _color, _lucky));
        // matchIdToPlayers[_matchId] = players;
    }

    function battleResult(uint256 _matchId) public returns (Player memory) {
        Player[] memory players = matchIdToPlayers[_matchId];
        Player memory winner = players[0];
        matchIdToWinner[_matchId] = winner;
        return winner;
    }
}
