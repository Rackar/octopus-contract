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

通过constructor 初始化ERC20代币合约，合约持有者为当前合约。

mint时可提取数字直接变化，但要24小时后才能claim

前端用已变后数字，然后查询事件是否在24小时内有mint，减掉power然后根据时间递增


0x0000000000000000000000000000000000000000

https://docs.soliditylang.org/en/v0.8.10/contracts.html#events

https://web3js.readthedocs.io/en/v1.5.2/web3-eth-contract.html#events

需要调试已发布的合约，需要找回对应的代码，激活状态下输入atAddress，可以调试。

