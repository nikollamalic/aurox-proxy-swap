import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

interface IUSDC {
    function balanceOf(address account) external view returns (uint256);

    function mint(address to, uint256 amount) external;

    function configureMinter(
        address minter,
        uint256 minterAllowedAmount
    ) external;

    function masterMinter() external view returns (address);
}

contract Faucet is Test {
    address tester;

    constructor(address _tester) {
        tester = _tester;
    }

    function mockUSDC(uint256 _amount) public {
        IUSDC usdc = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        vm.prank(usdc.masterMinter());

        // allow this test contract to mint USDC
        usdc.configureMinter(address(this), type(uint256).max);

        usdc.mint(tester, _amount);

        assertEq(usdc.balanceOf(tester), _amount);
    }

    function mockETH(uint256 _amount) public payable {
        vm.prank(tester);
        vm.deal(tester, _amount);

        assertEq(tester.balance, _amount);
    }

    function setUp(uint256 _amount) public {
        mockUSDC(_amount);
        mockETH(_amount);
    }
}
