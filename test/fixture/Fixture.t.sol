import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@aurox/AuroxSwapProxy.sol";
import "@aurox/interfaces/IAuroxSwapProxy.sol";

import "./Faucet.t.sol";

abstract contract Fixture is Test {
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

    function setUp() public virtual {
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

        require(bytes(MAINNET_RPC_URL).length > 0, "MAINNET_RPC_URL is empty");

        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        vm.rollFork(18485380);

        auroxSwapProxy = new AuroxSwapProxy(address(this));

        new Faucet(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496).setUp(10 ether);
    }
}
