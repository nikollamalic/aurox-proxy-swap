// SPDX-License-Identifier: MIT

import "./fixture/Fixture.t.sol";

import "forge-std/console.sol";

import "@aurox/interfaces/IAuroxSwapProxy.sol";

contract Swap is Fixture {
    function setUp() public override {
        super.setUp();

        address[] memory _whitelistAddresses = new address[](1);

        _whitelistAddresses[0] = 0x1111111254EEB25477B68fb85Ed929f73A960582;

        whitelistAddresses(_whitelistAddresses);
    }

    function testSwap() public {
        IERC20Extension(usdc).approve(
            address(auroxSwapProxy),
            type(uint256).max
        );

        auroxSwapProxy.swapWithFee(
            IERC20Extension(usdc),
            IERC20Extension(urus),
            IAuroxSwapProxy.SwapParams(
                0x1111111254EEB25477B68fb85Ed929f73A960582,
                95329930,
                0,
                "0xf78dc253000000000000000000000000c65f7b26a7bba778efd39641c46599bbdbecccf7000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000000000000000000000000000000000000005ae9e8f00000000000000000000000000000000000000000000000000b34dc13ea99f2500000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000140000000000000003b6d03403aa370aacf4cb08c7e1e7aa8e8ff9418d73c7e0f8b1ccac8"
            ),
            0,
            0
        );

        assertEq(true, true);
    }
}
