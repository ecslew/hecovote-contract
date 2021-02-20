pragma solidity ^0.6.0;

interface IHecovoteRegistry {
    function regist(string memory name,address owner) external;

    function getSpace(string memory name) external view returns (address);

    function spaceExist(string memory name) external view returns (bool);
}
