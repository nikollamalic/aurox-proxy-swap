// SPDX-License-Identifier: MIT
/**
 * @dev Part of the Chainlink Feed Registry standard
 */
interface IFeedRegistry {
    function getRoundData(
        address base,
        address quote,
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}
