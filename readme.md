# solidity
一些用法在新版本编译过程中报错，整理一下。
msg.sender == address(0);
这个用法报错，换为owner类 constructor

基类modifier 不需要加public internal等，子类直接用

## time
now 不让用，使用原名 block.timestamp
一个单位为秒，一个为微秒
block.timestamp = 1636512643

js Date.now()=1636512646839

test params
1636513488
1636514488
1636515488

address(this) 本合约地址

文档： https://ethereum.org/en/developers/tutorials/transfers-and-approval-of-erc-20-tokens-from-a-solidity-smart-contract/