// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

interface IL1ERC20Gateway {
    function getL2ERC20Address(address _l1Token) external view returns (address);
    function depositERC20(
        address _token,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;
    function depositERC20(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;
    function depositERC20AndCall(
        address _token,
        address _to,
        uint256 _amount,
        bytes memory _data,
        uint256 _gasLimit
    ) external payable;
    function finalizeWithdrawERC20(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) external payable;
}

interface L1GatewayRouter is IL1ERC20Gateway {
    function getL2ERC20Address(address _l1Address) external view override returns (address);
    function getERC20Gateway(address _token) external view returns (address);
}

contract GatewayTest is Test {
    MyToken public myToken;

    L1GatewayRouter router = L1GatewayRouter(0xe5E30E7c24e4dFcb281A682562E53154C15D3332);
    IL1ERC20Gateway defaultERC20Gateway = IL1ERC20Gateway(0xeF37207c1A1efF6D6a9d7BfF3cF4270e406d319b);


    function setUp() public {
        myToken = new MyToken();
    }

    function testERC20Gateway() public {
        uint bridgeTokenAmount = 1_000 * 1 ether;

        myToken.approve(
            address(defaultERC20Gateway),
            bridgeTokenAmount);

        defaultERC20Gateway.depositERC20{value: 0.0001 ether}(
            address(myToken),
            bridgeTokenAmount,
            5000
        );
    }

    function testRouterAllowingRouter() public {
        uint bridgeTokenAmount = 1_000 * 1 ether;

        console.logAddress(router.getERC20Gateway(address(myToken)));

        myToken.approve(
            address(router),
            bridgeTokenAmount);


        router.depositERC20{value: 0.0001 ether}(
            address(myToken),
            bridgeTokenAmount,
            5000
        );
    }

    function testRouterAllowingDefaultGateway() public {
        uint bridgeTokenAmount = 1_000 * 1 ether;

        console.logAddress(router.getERC20Gateway(address(myToken)));

        myToken.approve(
            address(defaultERC20Gateway),
            bridgeTokenAmount);


        router.depositERC20{value: 0.0001 ether}(
            address(myToken),
            bridgeTokenAmount,
            5000
        );
    }
}
