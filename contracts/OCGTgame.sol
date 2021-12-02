pragma solidity ^0.8.3;

// SPDX-License-Identifier: MIT
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
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

contract OCGTgame is Ownable, VRFConsumerBase {
    /***************
     * ChainLink part
     *****************/

    bytes32 internal keyHash;
    uint256 internal fee;

    mapping(bytes32 => uint256) public randomResults;

    /**
     * Requests randomness
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    function getRandomOneInTen(uint256 randomness)
        internal
        pure
        returns (uint256)
    {
        return randomness % 10;
    }

    function getRandomOneInThree(uint256 randomness)
        internal
        pure
        returns (uint256)
    {
        return randomness % 3;
    }

    function expand(uint256 randomValue, uint256 n)
        public
        pure
        returns (uint256[] memory expandedValues)
    {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResults[requestId] = randomness;
    }

    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }

    function getMatchResultPlayers(uint256 _matchId)
        internal
        view
        returns (
            Player[] memory,
            Player[] memory,
            Player[] memory
        )
    {
        uint256[] memory randoms = expand(randomResults[bytes32(_matchId)], 3);
        uint256 randomOneInTen = getRandomOneInTen(randoms[0]);
        uint256 randomOneInThree = getRandomOneInThree(randoms[1]);
        Player[] memory players = matchIdToPlayers[_matchId];

        uint256 resultCount;
        uint256 colorCount;
        uint256 luckyCount;

        for (uint256 i = 0; i < players.length; i++) {
            Player memory player = players[i];
            if (
                checkColor(randomOneInThree, player.color) &&
                checkLucky(randomOneInTen, player.lucky)
            ) {
                resultCount++;
            } else if (
                checkColor(randomOneInThree, player.color) &&
                !checkLucky(randomOneInTen, player.lucky)
            ) {
                colorCount++;
            } else if (
                !checkColor(randomOneInThree, player.color) &&
                checkLucky(randomOneInTen, player.lucky)
            ) {
                luckyCount++;
            }
        }

        Player[] memory result = new Player[](resultCount); // step 2 - create the fixed-length array
        Player[] memory resultColor = new Player[](colorCount); // step 2 - create the fixed-length array
        Player[] memory resultLucky = new Player[](luckyCount); // step 2 - create the fixed-length array
        uint256 j;
        uint256 k;
        uint256 m;

        for (uint256 i = 0; i < players.length; i++) {
            Player memory player = players[i];

            if (
                checkColor(randomOneInThree, player.color) &&
                checkLucky(randomOneInTen, player.lucky)
            ) {
                result[j] = players[i];
                j++;
            } else if (
                checkColor(randomOneInThree, player.color) &&
                !checkLucky(randomOneInTen, player.lucky)
            ) {
                resultColor[k] = players[i];
                k++;
            } else if (
                !checkColor(randomOneInThree, player.color) &&
                checkLucky(randomOneInTen, player.lucky)
            ) {
                resultLucky[m] = players[i];
                m++;
            }
        }

        return (result, resultColor, resultLucky); // step 4 - return
    }

    function checkColor(uint256 x, string memory color)
        public
        pure
        returns (bool)
    {
        if (
            x == 0 &&
            keccak256(abi.encodePacked(color)) ==
            keccak256(abi.encodePacked("red"))
        ) {
            return true;
        } else if (
            x == 1 &&
            keccak256(abi.encodePacked(color)) ==
            keccak256(abi.encodePacked("green"))
        ) {
            return true;
        } else if (
            x == 2 &&
            keccak256(abi.encodePacked(color)) ==
            keccak256(abi.encodePacked("blue"))
        ) {
            return true;
        } else {
            return false;
        }
    }

    // parseInt
    // function parseInt(string memory _a) public pure returns (uint256) {
    //     return parseInt(_a, 0);
    // }

    // // parseInt(parseFloat*10^_b)
    // function parseInt(string memory _a, uint256 _b)
    //     public
    //     pure
    //     returns (uint256)
    // {
    //     bytes memory bresult = bytes(_a);
    //     uint256 mint = 0;
    //     bool decimals = false;
    //     for (uint256 i = 0; i < bresult.length; i++) {
    //         if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
    //             if (decimals) {
    //                 if (_b == 0) break;
    //                 else _b--;
    //             }
    //             mint *= 10;
    //             mint += uint256(bresult[i]) - 48;
    //         } else if (bresult[i] == 46) decimals = true;
    //     }
    //     if (_b > 0) mint *= 10**_b;
    //     return mint;
    // }

    function checkLucky(uint256 luckyNumber, string memory lucky)
        public
        pure
        returns (bool)
    {
        if (
            keccak256(abi.encodePacked(bytes(lucky))) ==
            keccak256(abi.encodePacked(bytes32(luckyNumber)))
        ) {
            return true;
        } else {
            return false;
        }
    }

    function getMatchResult(uint256 _matchId) public {
        uint256[] memory randoms = expand(randomResults[bytes32(_matchId)], 3);
        uint256 randomOneInTen = getRandomOneInTen(randoms[0]);
        uint256 randomOneInThree = getRandomOneInThree(randoms[1]);
        Player[] memory players = matchIdToPlayers[_matchId];
        uint256[] memory winners;

        for (uint256 i = 0; i < players.length; i++) {
            Player memory player = players[i];
            if (
                checkColor(randomOneInThree, player.color) &&
                checkLucky(randomOneInTen, player.lucky)
            ) {
                rewordWinner(player.userAddress);
            } else if (
                checkColor(randomOneInThree, player.color) &&
                !checkLucky(randomOneInTen, player.lucky)
            ) {
                rewordWinnerColor(player.userAddress);
            } else if (
                !checkColor(randomOneInThree, player.color) &&
                checkLucky(randomOneInTen, player.lucky)
            ) {
                rewordWinnerLucky(player.userAddress);
            }
        }
    }

    function rewordWinner(address _userAddress) internal {}

    function rewordWinnerColor(address _userAddress) internal {}

    function rewordWinnerLucky(address _userAddress) internal {}

    /***************
     * data struct part
     *****************/

    OCGTtoken public token;
    bool canMintCoin;
    uint256 mintGapSecond = 24 * 60 * 60;
    uint256 coinExchangeRate = 1000000;

    constructor()
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088 // LINK Token
        )
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)

        address tokenAddress = 0xE1002B13E4294f6e7981DC25B96520E724261133;
        token = OCGTtoken(tokenAddress);
        canMintCoin = true;
    }

    function resetToken(address _token) public onlyOwner {
        token = OCGTtoken(_token);
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

    struct MatchResult {
        uint256 matchId;
        uint256 pool;
        address winner;
        string color;
        string lucky;
    }

    Match[] public matches;
    Match currentMatch;

    mapping(address => bool) public alreadyInPlayer;
    mapping(uint256 => Player[]) matchIdToPlayers;
    mapping(uint256 => Player) matchIdToWinner;
    mapping(address => uint256) unClaimCoinInMint;
    mapping(address => uint256) userMintStartTime;
    mapping(address => address[]) userInvited;

    mapping(address => uint256) ethBalance;

    /*******************************
    payable part
    *******************************/

    function deposit() public payable {
        // require(msg.value >= 0);
        // require(canMintCoin);
        // token.mint(msg.sender, msg.value);
        ethBalance[msg.sender] += msg.value;
    }

    function withdraw() public {
        // payable(msg.sender, token.balanceOf(msg.sender));
        uint256 _value = ethBalance[msg.sender];
        require(_value > 0, "no balance");
        ethBalance[msg.sender] = 0;
        payable(msg.sender).transfer(_value);
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    /*******************************
    manager part
    *******************************/

    event MatchCreated(
        uint256 allowJoinStartTime,
        uint256 allowJoinEndTime,
        uint256 gamePlanStartTime,
        uint256 playerLimit,
        uint256 matchId
    );

    event MatchJoined(
        uint256 matchId,
        address userAddress,
        string color,
        string lucky
    );

    event MatchStarted(uint256 matchId, uint256 gamePlanStartTime);

    event MatchEnded(
        uint256 matchId,
        uint256 pool,
        address winner,
        string color,
        string lucky
    );

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

    function createNewMatch(
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

        emit MatchCreated(
            _allowJoinStartTime,
            _allowJoinEndTime,
            _gamePlanStartTime,
            _playerLimit,
            index
        );
    }

    function startBattle(uint256 _matchId)
        public
        onlyOwner
        returns (Player memory)
    {
        Player[] memory players = matchIdToPlayers[_matchId];
        Player memory winner = players[0];
        matchIdToWinner[_matchId] = winner;
        return winner;
    }

    function changeCoinExchangeRate(uint256 _rate) external onlyOwner {
        coinExchangeRate = _rate;
    }

    /*******************************
    user part
    *******************************/

    event MintCoin(address indexed user, uint256 startTime, uint256 power);
    event InviteSuccess(
        address indexed invitingAddress,
        uint256 invitedCount,
        address indexed invitedAddress
    );

    function buyCoin() external payable {
        require(msg.value >= 0.001 ether, "value not enough");
        require(
            (coinExchangeRate * msg.value) / 1000000000000000 <=
                token.balanceOf(address(this)),
            "pool not enough"
        );
        token.transfer(
            msg.sender,
            (coinExchangeRate * msg.value) / 1000000000000000
        );
    }

    function mintCoin(uint256 _power, address _whoInviteMe)
        external
        returns (bool)
    {
        uint256 timeNow = block.timestamp;
        require(canMintCoin, "Can not mint yet");
        // require(msg.value >= 0.001 ether, "the value be sended not enough");
        require(
            userMintStartTime[msg.sender] <= (timeNow - mintGapSecond),
            "you had mint yet, wait for gap end"
        );
        userMintStartTime[msg.sender] = timeNow;
        unClaimCoinInMint[msg.sender] += _power;
        emit MintCoin(msg.sender, timeNow, _power);

        // check if user invite me
        if (_whoInviteMe != msg.sender && !alreadyInPlayer[msg.sender]) {
            alreadyInPlayer[msg.sender] = true;
            if (_whoInviteMe != address(0)) {
                userInvited[_whoInviteMe].push(msg.sender);
                emit InviteSuccess(
                    _whoInviteMe,
                    userInvited[_whoInviteMe].length,
                    msg.sender
                );
            }
        }
        return true;
    }

    function coinCanClaim(address _user) public view returns (uint256) {
        return unClaimCoinInMint[_user];
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
    ) public {
        Player[] storage players = matchIdToPlayers[_matchId];
        players.push(Player(msg.sender, _matchId, _color, _lucky));
        matchIdToPlayers[_matchId] = players;
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= 500, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), 500); //测试是否传输报错
    }

    /*******************************
    test part
    *******************************/
    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getBalance(address _user) public view returns (uint256) {
        return token.balanceOf(_user);
    }

    function getNow() public view returns (uint256) {
        return block.timestamp;
    }
}
