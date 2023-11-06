// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IERC20Extension.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IOracle.sol";

import "../libraries/Constants.sol";

contract UniswapV2Oracle is IOracle {
    IWETH constant WETH = IWETH(Constants.WETH);

    IUniswapV2Factory constant uniswapV2Factory =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    IUniswapV2Router02 public immutable uniswapV2Router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    /// @dev Simple wrapper for the swapTokensForExactETH uniswap V2 function
    function _swapTokensForExactETH(
        IERC20 _token,
        uint256 _amountOut,
        uint256 _amountInMaximum,
        address _to
    ) internal returns (uint256 amountIn, uint256 amountOut) {
        // If we are swapping from WETH -> ETH we need to wrap the ETH instead via the WETH contract. This is also exchanged 1:1 for ETH, so we can just pass the required _amountOut
        if (_token == WETH) {
            WETH.withdraw(_amountOut);

            return (_amountOut, _amountOut);
        }

        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = address(WETH);

        uint256[] memory amounts = uniswapV2Router.swapTokensForExactETH(
            _amountOut,
            _amountInMaximum,
            path,
            _to,
            block.timestamp
        );

        return (amounts[0], amounts[1]);
    }

    /// @notice This function calculates a path for swapping _fromToken for _toToken
    function _returnUniswapV2Path(
        IERC20 _fromToken,
        IERC20 _toToken
    ) internal view returns (address[] memory path) {
        // Try to find a direct pair address for the given tokens
        try
            uniswapV2Factory.getPair(address(_fromToken), address(_toToken))
        returns (address _pairAddress) {
            // If a direct pair exists, return the direct path
            if (_pairAddress != address(0)) {
                // Been finding some direct pairs have old pools no one uses, so get the timestamp when the pool was used last
                (, , uint256 blocktimestampLast) = IUniswapV2Pair(_pairAddress)
                    .getReserves();

                // If the pool has been used within the last day, then route through the pool. If its been inactive longer than a day then its highly likely its a low liquidity pool and we don't want to route through it.

                // This is a cheap solution, it could pull the reserves from the pool and calculate the amount of stored liquidity in the pool in ETH and invalidate if less than a liquidity threshold. But that would cost a lot more gas and this seems ok for the current MVP
                if (block.timestamp - blocktimestampLast < 86400) {
                    path = new address[](2);

                    path[0] = address(_fromToken);
                    path[1] = address(_toToken);

                    return path;
                }
            }
        } catch {}

        // Return an empty path here, the route can't be handled if either of the tokens are WETH
        if (_fromToken == WETH || _toToken == WETH) {
            return path;
        }

        // Otherwise create a path through WETH
        path = new address[](3);

        path[0] = address(_fromToken);
        path[1] = address(WETH);
        path[2] = address(_toToken);
    }

    /// @dev Simple wrapper for the swapExactTokensForTokens uniswap V2 function
    function _swapExactTokensForTokens(
        IERC20 _fromToken,
        IERC20 _toToken,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) internal returns (uint256 amountIn, uint256 amountOut) {
        address[] memory path = _returnUniswapV2Path(_fromToken, _toToken);

        uint256[] memory amounts = uniswapV2Router.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );

        // Return the first item and the last item, so that it adheres to the path length
        return (amounts[0], amounts[path.length - 1]);
    }

    /// @dev Simple wrapper for the swapExactETHForTokens uniswap V2 function
    function _swapExactETHForTokens(
        IERC20 _token,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) internal returns (uint256 amountIn, uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(_token);

        uint256[] memory amounts = uniswapV2Router.swapExactETHForTokens{
            value: _amountIn
        }(_amountOutMin, path, _to, block.timestamp);

        return (amounts[0], amounts[1]);
    }

    /// @dev Simple wrapper for the swapExactTokensForETH uniswap V2 function
    function _swapExactTokensForETH(
        IUniswapV2Router02 _uniswapV2Router,
        IERC20 _token,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) internal returns (uint256 amountIn, uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = address(WETH);

        uint256[] memory amounts = _uniswapV2Router.swapExactTokensForETH(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );

        return (amounts[0], amounts[1]);
    }

    function _getUniswapV2Rate(
        IERC20Extension _fromToken,
        IERC20Extension _toToken
    ) internal view returns (uint256) {
        // Uniswap doesn't handle the ETH contract (0xeee), so update to WETH address for rate fetching
        if (address(_fromToken) == Constants.ETH) {
            _fromToken = WETH;
        }

        if (address(_toToken) == Constants.ETH) {
            _toToken = WETH;
        }

        // The rate fetching path
        address[] memory path = _returnUniswapV2Path(_fromToken, _toToken);

        // The return path function will return an array of 0x0 addresses if it can't find a valid path
        if (path.length == 0) return 0;

        // To calculate the amount we need to provide an amountIn. This needs to be normalised based on the amount of decimals in the given _fromToken.
        uint8 inputDecimals = address(_fromToken) == Constants.ETH
            ? 18
            : _fromToken.decimals();

        // Apply the decimals to the amount
        uint256 amountIn = 1 * 10 ** inputDecimals;

        // Safely call the method
        try uniswapV2Router.getAmountsOut(amountIn, path) returns (
            uint256[] memory rate
        ) {
            return rate[path.length - 1];
        } catch {
            return 0;
        }
    }

    function getPrice(
        address fromToken,
        address toToken
    ) external view override returns (uint256) {
        return
            _getUniswapV2Rate(
                IERC20Extension(fromToken),
                IERC20Extension(toToken)
            );
    }

    function swapTokens(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn
    ) external override returns (uint256 amountReceived) {
        if (fromToken == Constants.ETH) {
            (, amountReceived) = _swapTokensForExactETH(
                IERC20Extension(toToken),
                amount,
                minReturn,
                msg.sender
            );
        } else if (toToken == Constants.ETH) {
            (, amountReceived) = _swapExactTokensForETH(
                uniswapV2Router,
                IERC20Extension(fromToken),
                amount,
                minReturn,
                msg.sender
            );
        } else {
            _swapExactTokensForTokens(
                IERC20Extension(fromToken),
                IERC20Extension(toToken),
                amount,
                minReturn,
                msg.sender
            );
        }

        if (amountReceived < minReturn) {
            revert NotEnoughFundsReturned(minReturn, amountReceived);
        }
    }
}
