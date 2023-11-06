// SPDX-License-Identifier: MIT
import {Test} from "forge-std/Test.sol";

import "../fixture/Fixture.t.sol";

import "@aurox/oracles/UniswapV2.sol";
import "@aurox/libraries/Constants.sol";

contract UniswapV2OracleTest is Test, Fixture {
    UniswapV2Oracle oracle;

    constructor() {
        oracle = new UniswapV2Oracle();

        vm.makePersistent(Constants.WETH);
        vm.makePersistent(Constants.ETH);

        super.setUp();
    }

    function testGetPrice_USDC_URUS() public {
        uint256 price = oracle.getPrice(address(usdc), address(urus));

        assertEq(price, 167228523751240216);
    }

    function testGetPrice_ETH_URUS() public {
        uint256 price = oracle.getPrice(Constants.ETH, address(urus));

        assertEq(price, 301489303347126058157);
    }

    function testGetPrice_URUS_USDC() public {
        uint256 price = oracle.getPrice(address(urus), address(usdc));

        assertEq(price, 5908238);
    }

    function testGetPrice_URUS_ETH() public {
        uint256 price = oracle.getPrice(address(urus), Constants.ETH);

        assertEq(price, 3272965639457328);
    }

    function testGetPrice_USDC_ETH() public {
        uint256 price = oracle.getPrice(address(usdc), Constants.ETH);

        assertEq(price, 550647495860747);
    }

    function testGetPrice_ETH_USDC() public {
        uint256 price = oracle.getPrice(Constants.ETH, address(usdc));

        assertEq(price, 1805052085);
    }

    function testGetPrice_WETH_USDC() public {
        uint256 price = oracle.getPrice(Constants.WETH, address(usdc));

        assertEq(price, 1805052085);
    }

    function testGetPrice_USDC_WETH() public {
        uint256 price = oracle.getPrice(address(usdc), Constants.WETH);

        assertEq(price, 550647495860747);
    }
}
