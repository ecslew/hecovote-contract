// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interfaces/ISimpleERCFund.sol";
import "./interfaces/IGoSwapRouter.sol";
import "./owner/Operator.sol";

contract HecovoteRegistry is Operator {
    /// @dev 注册表映射
    mapping(bytes32 => address) private _registry;
    /// @dev 注册事件
    event Regist(string name, address owner);

    /*
     * @dev 注册空间
     * @param name 空间名称
     */
    function regist(string memory name,address owner) public onlyOperator {
        // 将名称转换为hash
        bytes32 hash = keccak256(abi.encode(name));
        // 确认hash不存在
        require(_registry[hash] == address(0), "Name aleardy exist!");
        // 注册hash映射
        _registry[hash] = owner;
        // 触发事件
        emit Regist(name, owner);
    }

    /*
     * @dev 返回注册空间的地址
     * @param name 空间名称
     * @return 空间地址
     */
    function getSpace(string memory name) public view returns (address) {
        // 将名称转换为hash
        bytes32 hash = keccak256(abi.encode(name));
        // 返回hash对应的地址
        return _registry[hash];
    }

    /*
     * @dev 返回是否存在注册空间
     * @param name 空间名称
     * @return 是否存在
     */
    function spaceExist(string memory name) public view returns (bool) {
        // 将名称转换为hash
        bytes32 hash = keccak256(abi.encode(name));
        // 返回hash不等于地址0
        return _registry[hash] != address(0);
    }
}
