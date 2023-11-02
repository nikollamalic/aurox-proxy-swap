// SPDX-License-Identifier: MIT
/**
 * @dev Part of the Chainlink Feed Registry standard
 * https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol
 */
interface IFeedRegistry {
    function latestRoundData(
        address base,
        address quote
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
