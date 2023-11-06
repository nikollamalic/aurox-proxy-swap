import {Test} from "forge-std/Test.sol";

import "../fixture/Fixture.t.sol";

import "@aurox/oracles/Chainlink.sol";
import "@aurox/libraries/Constants.sol";

contract ChainlinkOracleTest is Test, Fixture {
    ChainlinkOracle oracle;

    constructor() {
        oracle = new ChainlinkOracle();

        vm.makePersistent(Constants.WETH);
        vm.makePersistent(Constants.ETH);

        super.setUp();
    }

    function testGetPrice_USDC_URUS() public {
        uint256 price = oracle.getPrice(address(usdc), address(urus));

        assertEq(price, 0);
    }

    function testGetPrice_ETH_URUS() public {
        uint256 price = oracle.getPrice(Constants.ETH, address(urus));

        assertEq(price, 0);
    }

    function testGetPrice_URUS_USDC() public {
        uint256 price = oracle.getPrice(address(urus), address(usdc));

        assertEq(price, 0);
    }

    function testGetPrice_URUS_ETH() public {
        uint256 price = oracle.getPrice(address(urus), Constants.ETH);

        assertEq(price, 0);
    }

    function testGetPrice_USDC_ETH() public {
        uint256 price = oracle.getPrice(address(usdc), Constants.ETH);

        assertEq(price, 551699134561816);
    }

    function testGetPrice_ETH_USDC() public {
        uint256 price = oracle.getPrice(Constants.ETH, address(usdc));

        assertEq(price, 1812582143);
    }

    function testGetPrice_WETH_USDC() public {
        uint256 price = oracle.getPrice(Constants.WETH, address(usdc));

        assertEq(price, 1812582143);
    }

    function testGetPrice_USDC_WETH() public {
        uint256 price = oracle.getPrice(address(usdc), Constants.WETH);

        assertEq(price, 551699134561816);
    }
}
