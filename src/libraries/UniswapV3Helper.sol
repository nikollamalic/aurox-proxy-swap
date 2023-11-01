pragma solidity ^0.8.19;

import "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-periphery/interfaces/IQuoter.sol";
import "v3-periphery/interfaces/ISwapRouter.sol";

/// Should help with swapping and fetching quotes from Uniswap V3
library UniswapV3Helper {
    IUniswapV3Factory public constant poolFactory =
        IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

    IQuoter public constant quoter =
        IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

    ISwapRouter public constant swapRouter =
        IRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    function getQuote(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external returns (uint256 quote) {
        require('amountIn > 0', 'amountIn must be greater than 0');

        address pool = poolFactory.getPool(_tokenIn, _tokenOut, 3000);

        if (pool == address(0)) {
            return 0;
        }

        try
            quoter.quoteExactInputSingle(
                _tokenIn,
                _tokenOut,
                3000,
                _amountIn,
                0
            )
        returns (uint256 amountOut) {
            return amountOut / amountIn;
        } catch {
            return 0;
        }
    }

    function exactInputSingle(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMinimum
    ) external returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 300,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMinimum,
                sqrtPriceLimitX96: 0
            });

        try swapRouter.exactInputSingle(params) returns (uint256 amountOut) {
            return amountOut;
        } catch {
            return 0;
        }
    }
}
