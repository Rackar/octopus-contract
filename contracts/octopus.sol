pragma solidity ^0.8.3;

// SPDX-License-Identifier: MIT
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor()  {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract OCGT is Ownable {
    struct Player {
        address userAddress;
        uint256 matchId;
        string color;
        string lucky;
    }
    struct Match {
        uint256 allowJoinStartTime;
        uint256 allowJoinEndTime;
        uint256 gamePlanStartTime;
        uint256 playerLimit;
        uint256 matchId;
    }

    Match[] public matches;
    Match currentMatch;

    mapping(uint256 => Player[]) matchIdToPlayers;
    mapping(uint256 => Player) matchIdToWinner;

    function startNewMatch( uint256 _allowJoinStartTime,uint256 _allowJoinEndTime,uint256 _gamePlanStartTime, uint256 _playerLimit)
        public onlyOwner
    {
        require(_allowJoinStartTime < _allowJoinEndTime);
        require(_allowJoinEndTime < _gamePlanStartTime);
        require(_allowJoinEndTime > block.timestamp);
        uint256 index = matches.length+1;
        currentMatch = Match(_allowJoinStartTime,_allowJoinEndTime,_gamePlanStartTime, _playerLimit, index);
        matches.push(currentMatch);
    }

    function getCurentMatchId() public view returns (uint256) {
        uint256 limitTime = currentMatch.gamePlanStartTime;
        if( block.timestamp >= limitTime) {
            return 0;
        }else{
            return currentMatch.matchId;
        }
    }

    function getNow() public view returns (uint256) {
        return block.timestamp;
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
