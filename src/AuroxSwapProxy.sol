// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IERC20Extension.sol";

import "@aurox/Base.sol";
import "@aurox/periphery/Whitelist.sol";

import "forge-std/console.sol";

/// @title ForwardingSwapProxy
contract AuroxSwapProxy is
    IAuroxSwapProxy,
    AccessControlEnumerable,
    Pausable,
    ReentrancyGuard,
    BaseSwapProxy,
    Whitelist
{
    constructor(address _admin) BaseSwapProxy(_admin) Whitelist(_admin) {}

    function _validateSwap(
        IERC20Extension _fromToken,
        IERC20Extension _toToken,
        address _swapContract
    ) internal view {
        require(_fromToken != _toToken, "_fromToken equal to _toToken");

        console.log("Swap contract", _swapContract);

        if (!isWhitelisted(_swapContract)) {
            revert NotWhitelisted(_swapContract);
        }
    }

    function _handleSwapCompletion(
        IERC20Extension _fromToken,
        IERC20Extension _toToken,
        uint256 _amountRequested,
        uint256 _amountReturned,
        uint256 _feeTotalInETH
    ) internal {
        if (_feeTotalInETH != 0) {
            vault.paidFees{value: _feeTotalInETH}(msg.sender, _feeTotalInETH);
        }

        emit AuroxSwap(
            address(_fromToken),
            address(_toToken),
            _amountRequested,
            _amountReturned,
            _feeTotalInETH
        );
    }

    function swapWithFee(
        IERC20Extension _fromToken,
        IERC20Extension _toToken,
        SwapParams calldata _swapParams,
        uint256 _gasRefund,
        uint256 _minimumReturnAmount
    ) external payable override whenNotPaused nonReentrant {
        _validateSwap(_fromToken, _toToken, _swapParams.to);

        (
            uint256 amountRequested,
            uint256 amountReturned,
            uint256 feeTotalInETH
        ) = _swapTokens(
                _fromToken,
                _toToken,
                _swapParams,
                _gasRefund,
                _minimumReturnAmount
            );

        _handleSwapCompletion(
            _fromToken,
            _toToken,
            amountRequested,
            amountReturned,
            feeTotalInETH
        );
    }

    function swapWithPermit(
        IERC20Extension _fromToken,
        IERC20Extension _toToken,
        SwapParams calldata _swapParams,
        uint256 _minimumReturnAmount,
        uint256 _gasRefund,
        IPermit2.PermitSingle calldata _permit,
        bytes calldata _signature
    ) external override whenNotPaused nonReentrant {
        _validateSwap(_fromToken, _toToken, _swapParams.to);

        (
            uint256 amountRequested,
            uint256 amountReturned,
            uint256 feeTotalInETH
        ) = _swapTokens(
                _fromToken,
                _toToken,
                _swapParams,
                _gasRefund,
                _minimumReturnAmount,
                _permit,
                _signature
            );

        _handleSwapCompletion(
            _fromToken,
            _toToken,
            amountRequested,
            amountReturned,
            feeTotalInETH
        );
    }

    function getExchangeRate(
        IERC20Extension _fromToken,
        IERC20Extension _toToken
    ) external view returns (uint256) {
        return _getExchangeRate(_fromToken, _toToken);
    }

    function calculatePercentageFeeInETH(
        IERC20Extension _token,
        uint256 _amount,
        uint256 _gasRefund
    )
        external
        view
        returns (uint256 feeTotalInETH, uint256 feeTotalInToken)
    {
        return _calculatePercentageFeeInETH(_token, _amount, _gasRefund);
    }
}
