pragma solidity ^0.8.3;

// SPDX-License-Identifier: MIT
import "./OCGTtoken.sol";

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
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

contract OCGTgame is Ownable {
    OCGTtoken public token;
    bool canMintCoin;
    uint256 mintGapSecond = 24 * 60 * 60;

    constructor() {
        token = new OCGTtoken();
        canMintCoin = true;
    }

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
    mapping(address => uint256) unClaimCoinInMint;
    mapping(address => uint256) userMintStartTime;
    mapping(address => address[]) userInvited;

    mapping(address => uint256) ethBalance;

    /*
    payable part
    */

    function deposit() public payable {
        // require(msg.value >= 0);
        // require(canMintCoin);
        // token.mint(msg.sender, msg.value);
        ethBalance[msg.sender] += msg.value;
    }

    function withdraw() public {
        // payable(msg.sender, token.balanceOf(msg.sender));
        payable(msg.sender).transfer(ethBalance(msg.sender));
        ethBalance[msg.sender] = 0;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    /*
    manager part
    */

    function changeMintGap(uint256 _gap) public onlyOwner {
        mintGapSecond = _gap;
    }

    function switchMint(bool _canMint) public onlyOwner {
        require(canMintCoin != _canMint, "already is this mint status");
        canMintCoin = _canMint;
    }

    function approveAirdropToAddress(address _user, uint256 _amount)
        public
        onlyOwner
    {
        token.approve(_user, _amount);
    }

    function startNewMatch(
        uint256 _allowJoinStartTime,
        uint256 _allowJoinEndTime,
        uint256 _gamePlanStartTime,
        uint256 _playerLimit
    ) public onlyOwner {
        require(_allowJoinStartTime < _allowJoinEndTime);
        require(_allowJoinEndTime < _gamePlanStartTime);
        require(_allowJoinEndTime > block.timestamp);
        uint256 index = matches.length + 1;
        currentMatch = Match(
            _allowJoinStartTime,
            _allowJoinEndTime,
            _gamePlanStartTime,
            _playerLimit,
            index
        );
        matches.push(currentMatch);
    }

    /*
    user part
    */

    event MintCoin(address _user, uint256 _startTime, uint256 _power);

    function mintCoin(uint256 _power) public payable {
        uint256 timeNow = block.timestamp;
        require(canMintCoin, "Can not mint yet");
        require(msg.value >= 0.001 ether, "value wrong");
        require(
            userMintStartTime[msg.sender] <= (timeNow - mintGapSecond),
            "can not mint yet"
        );
        userMintStartTime[msg.sender] = timeNow;
        unClaimCoinInMint[msg.sender] += _power;
        emit MintCoin(msg.sender, timeNow, _power);
    }

    function coinCanClaim() public view returns (uint256) {
        return unClaimCoinInMint[msg.sender];
    }

    function claimMintCoin(uint256 _amount) public {
        require(
            unClaimCoinInMint[msg.sender] <= token.balanceOf(address(this)),
            "pool not enough"
        );
        require(_amount <= unClaimCoinInMint[msg.sender], "your not enough");
        unClaimCoinInMint[msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
    }

    function getCurentMatchId() public view returns (uint256) {
        uint256 limitTime = currentMatch.gamePlanStartTime;
        if (block.timestamp >= limitTime) {
            return 0;
        } else {
            return currentMatch.matchId;
        }
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
        require(msg.value == 0.00001 ether);
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

    /*
    test part
    */
    function getBalance(address _user) public view returns (uint256) {
        return token.balanceOf(_user);
    }

    function getNow() public view returns (uint256) {
        return block.timestamp;
    }
}
