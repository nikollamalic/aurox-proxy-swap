// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface IOracle {
error NotEnoughFundsReturned(uint256 amountRequested, uint256 amountReturned);

    /**
     * @dev Get the latest price for a given token pair.
     * @param fromToken The address of the first token in the pair.
     * @param toToken The address of the second token in the pair.
     * @return The latest price of fromToken in terms of toToken.
     */
    function getPrice(
        address fromToken,
        address toToken
    ) external view returns (uint256);

    /**
     * @dev Swap tokens for a specific amount.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amountIn The amount of fromToken to swap.
     * @param amountOut The amount of toToken to expect.
     * @return amountReceived The amount of toToken received in the swap.
     */
    function swapTokens(
        address fromToken,
        address toToken,
        uint256 amountIn,
        uint256 amountOut
    ) external returns (uint256 amountReceived);
}
