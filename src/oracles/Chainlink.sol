// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@aurox/interfaces/IOracle.sol";
import "@aurox/interfaces/IFeedRegistry.sol";
import "@aurox/interfaces/IERC20Extension.sol";

import "@aurox/libraries/DecimalScaler.sol";
import "@aurox/libraries/Constants.sol";

import {UD60x18, ud, intoUint256} from "prb-math/UD60x18.sol";
import {SD59x18, sd} from "prb-math/SD59x18.sol";

contract ChainlinkOracle is IOracle {
    using DecimalScaler for UD60x18;
    using DecimalScaler for uint256;

    // Chainlink feedRegistry
    IFeedRegistry public immutable feedRegistry =
        IFeedRegistry(0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf);

    function tryGetChainlinkRate(
        address _fromToken,
        address _toToken
    ) internal view returns (uint256) {
        // Because of how chainlink rates work, they never provide rates from ETH -> _toToken,
        // they always go _fromToken ->
        // So the rate needs to be inverted if the request is in the wrong direction
        bool invertRate = _fromToken == Constants.ETH;

        if (invertRate) {
            _fromToken = _toToken;
            _toToken = Constants.ETH;
        }

        try feedRegistry.latestRoundData(_fromToken, _toToken) returns (
            uint80 roundId,
            int256 chainlinkPrice,
            uint256,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            // Ensure that the chainlink response is valid. Not adding a revert message as the require statement is wrapped in a try-catch
            require(updatedAt > 0 && answeredInRound == roundId);

            if (!invertRate) {
                return uint256(chainlinkPrice);
            }

            return intoUint256(ud(1 ether) / (ud(uint256(chainlinkPrice))));
        } catch {
            return 0;
        }
    }

    function getPrice(
        address _fromToken,
        address _toToken
    ) external view override returns (uint256) {
        // Chainlink doesn't handle WETH, which seems a bit silly,
        // so modify it to use the 0xeee "ETH" contract
        if (_fromToken == Constants.WETH) {
            _fromToken = Constants.ETH;
        }

        if (_toToken == Constants.WETH) {
            _toToken = Constants.ETH;
        }

        uint8 _toDecimals = _toToken == Constants.ETH
            ? 18
            : IERC20Extension(_toToken).decimals();

        // Try to get a direct rate for the provided pair
        uint256 directRate = tryGetChainlinkRate(_fromToken, _toToken);

        if (directRate != 0) {
            return directRate.scale(18, _toDecimals);
        }

        // If no direct rate exists and either token is ETH, return now
        if (_fromToken == Constants.ETH || _toToken == Constants.ETH) {
            return 0;
        }

        // Otherwise try and get a rate by going: _fromToken -> ETH -> _toToken
        uint256 toETHRate = tryGetChainlinkRate(_fromToken, Constants.ETH);
        uint256 fromETHRate = tryGetChainlinkRate(Constants.ETH, _toToken);

        // If both rates returned, calculate the ratio between the two, then scale it to the correct decimals
        if (toETHRate != 0 && fromETHRate != 0) {
            return ud(toETHRate).mul(ud(fromETHRate)).scale(18, _toDecimals);
        }

        return 0;
    }

    function swapTokens(
        address fromToken,
        address toToken,
        uint256 amountIn,
        uint256 amountOut
    ) external pure override returns (uint256) {
        revert("Not implemented");
    }
}
