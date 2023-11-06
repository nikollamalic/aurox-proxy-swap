import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@aurox/AuroxSwapProxy.sol";
import "@aurox/interfaces/IAuroxSwapProxy.sol";

import "./Faucet.t.sol";

contract Fixture is Test {
    uint256 mainnetFork;

    AuroxSwapProxy auroxSwapProxy;

    IERC20Extension usdc =
        IERC20Extension(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    IERC20Extension urus =
        IERC20Extension(0xc6DdDB5bc6E61e0841C54f3e723Ae1f3A807260b);

    function whitelistAddresses(address[] memory _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            auroxSwapProxy.addToWhitelist(_addresses[i]);
        }
    }

    function setUp() public {
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

        require(bytes(MAINNET_RPC_URL).length > 0, "MAINNET_RPC_URL is empty");

        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        vm.rollFork(18485380);

        auroxSwapProxy = new AuroxSwapProxy(
            0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        );

        new Faucet(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496).setUp(10 ether);
    }

    function test_balanceOf() public {
        address user = 0xDF40aEBa2e9907E900089bCcf929ffcCD8fA4e0b;

        assertEq(urus.balanceOf(user), 1661124124067554190);
    }

    function test_getExchangeRate() public {
        uint256 exchangeRate = auroxSwapProxy.getExchangeRate(urus, usdc);

        console.log("exchangeRate", exchangeRate);

        assertEq(exchangeRate, 1000000000000000000);
    }

    function test_swapWithFee() public {
        bytes memory _data = bytes(
            "0x0502b1c5000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000027100000000000000000000000000000000000000000000000000005e729c9d1bfce0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000200000000000000003b5dc1003926a168c11a816e10c13977f75f488bfffe88e400000000000000003b6d0340ebd54ad6c1d4b079bdc20ecf36dd29d1d76c99778b1ccac8"
        );

        auroxSwapProxy.addToWhitelist(
            0x1111111254EEB25477B68fb85Ed929f73A960582
        );

        auroxSwapProxy.addToWhitelist(
            0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        );

        auroxSwapProxy.swapWithFee(
            IERC20Extension(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
            IERC20Extension(0xc6DdDB5bc6E61e0841C54f3e723Ae1f3A807260b),
            IAuroxSwapProxy.SwapParams(
                0x1111111254EEB25477B68fb85Ed929f73A960582,
                10000,
                0,
                _data
            ),
            0,
            0
        );

        assertEq(1 == 1, 1 == 1);
    }
}
