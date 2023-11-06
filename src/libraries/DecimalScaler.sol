// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UD60x18, ud, convert} from "prb-math/UD60x18.sol";

library DecimalScaler {
    /**
     * @notice Scale a number up or down to adjust the number of decimal places.
     * @param _amount The unsigned integer to be scaled.
     * @param _fromDecimals The number of decimal places in the original number.
     * @param _toDecimals The number of decimal places you want to scale to.
     * @return The scaled number with the desired number of decimal places.
     */
    function scale(
        uint256 _amount,
        uint8 _fromDecimals,
        uint8 _toDecimals
    ) internal pure returns (uint256) {
        if (_fromDecimals < _toDecimals) {
            return
                _amount * uint256(10 ** uint256(_toDecimals - _fromDecimals));
        }

        if (_fromDecimals > _toDecimals) {
            return
                _amount / uint256(10 ** uint256(_fromDecimals - _toDecimals));
        }

        return _amount;
    }

    function scale(
        UD60x18 _amount,
        uint8 _fromDecimals,
        uint8 _toDecimals
    ) internal pure returns (uint256) {
        if (_fromDecimals < _toDecimals) {
            return
                convert(
                    _amount.mul(ud(10 ** uint256(_toDecimals - _fromDecimals)))
                );
        }

        if (_fromDecimals > _toDecimals) {
            return
                convert(
                    _amount.div(ud(10 ** uint256(_fromDecimals - _toDecimals)))
                );
        }

        return convert(_amount);
    }
}
