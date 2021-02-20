// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IGoSwapRouter.sol";
import "./interfaces/IHecovoteRegistry.sol";
import "./interfaces/ISimpleERCFund.sol";
import "./owner/Operator.sol";

contract BuyRegistry is Operator {
    using SafeERC20 for IERC20;
    /// @notice 注册表合约
    IHecovoteRegistry public registry;
    /// @notice GOC地址
    address public constant GOC =
        address(0x271B54EBe36005A7296894F819D626161C44825C);
    /// @notice HUSD地址
    address public constant HUSD =
        address(0x0298c2b32eaE4da002a15f36fdf7615BEa3DA047);
    /// @notice GoSwap路由地址
    address public constant router =
        address(0xB88040A237F8556Cf63E305a06238409B3CAE7dC);
    /// @notice 开发者基金地址
    address public constant fund =
        address(0x57b91C4279A435913A64c490210d61978A0880C0);
    /// @notice 默认手续费
    uint256 public fee = 10 * 10**18;
    /// @notice 设置手续费事件
    event SetFee(uint256 fee);

    /*
     * @dev 构造函数
     */
    constructor(IHecovoteRegistry _registry) public {
        registry = _registry;
        // 将当前合约的GOC批准给开发者奖励基金
        IERC20(GOC).safeApprove(fund, uint256(-1));
        // 将当前合约的HUSD批准给路由合约
        IERC20(HUSD).safeApprove(router, uint256(-1));
    }

    /*
     * @dev 设置手续费
     * @param _fee 手续费
     */
    function setFee(uint256 _fee) public onlyOperator {
        fee = _fee;
        emit SetFee(fee);
    }

    /*
     * @dev 用GOC购买空间
     * @param name 空间名称
     */
    function GOCBuySapce(string memory name) public {
        // 将购买者的GOC发送到当前合约
        IERC20(GOC).safeTransferFrom(msg.sender, address(this), fee);
        // 调用fund合约的存款方法存入开发者准备金
        ISimpleERCFund(fund).deposit(GOC, fee, "BuyRegistry");
        // 注册名称
        registry.regist(name,msg.sender);
    }

    /*
     * @dev 用HUSD购买空间
     * @param name 空间名称
     */
    function HUSDBuySpace(string memory name) public {
        // 定义交易路径
        address[] memory path = new address[](2);
        path[0] = HUSD;
        path[1] = GOC;
        // 获取输入数额
        uint256[] memory amountsIn =
            IGoSwapRouter(router).getAmountsIn(fee, path);
        // 将输入数额的HUSD发送到当前合约
        IERC20(HUSD).safeTransferFrom(msg.sender, address(this), amountsIn[0]);
        // 调用GoSwap路由合约,用HUSD交换GOC
        IGoSwapRouter(router).swapTokensForExactTokens(
            fee,
            amountsIn[0],
            path,
            address(this),
            block.timestamp + 1800
        );

        // 调用fund合约的存款方法存入开发者准备金
        ISimpleERCFund(fund).deposit(GOC, fee, "BuyRegistry");
        // 注册名称
        registry.regist(name,msg.sender);
    }

    /*
     * @dev 返回注册空间的地址
     * @param name 空间名称
     * @return 空间地址
     */
    function getSpace(string memory name) public view returns (address) {
        return registry.getSpace(name);
    }

    /*
     * @dev 返回是否存在注册空间
     * @param name 空间名称
     * @return 是否存在
     */
    function spaceExist(string memory name) public view returns (bool) {
        return registry.spaceExist(name);
    }
}
