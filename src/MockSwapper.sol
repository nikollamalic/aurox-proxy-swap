pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPermit2 {
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice The permit message signed for a single token allownce
    struct PermitSingle {
        // the permit data for a single token alownce
        PermitDetails details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    function transferFrom(address from, address to, uint160 amount, address token) external;
}

contract MockSwapper {
    IPermit2 public immutable PERMIT2;

    constructor(IPermit2 _permit2) {
        PERMIT2 = _permit2;
    }

    function swap(
        IERC20 _token,
        address _receipt,
        uint160 _amount,
        IPermit2.PermitSingle calldata _permit,
        bytes calldata _signature
    ) external {
        PERMIT2.permit(
            // Owner of the tokens and signer of the message.
            msg.sender,
            // The permit message.
            _permit,
            // The packed signature that was the result of signing
            // the EIP712 hash of `_permit`.
            _signature
        );

        PERMIT2.transferFrom(msg.sender, _receipt, _amount, _permit.details.token);
    }
}
