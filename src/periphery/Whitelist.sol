import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@aurox/interfaces/IWhitelist.sol";

contract Whitelist is IWhitelist, AccessControlEnumerable {
    mapping(address => bool) whitelist;

    constructor(address _admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function isWhitelisted(address _address)
        public
        view
        override
        returns (bool)
    {
        return whitelist[_address];
    }

    function addToWhitelist(address _address)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            _address != address(0),
            "Can't add the 0x address to the whitelist"
        );
        whitelist[_address] = true;

        emit AddedToWhitelist(_address);
    }

    function removeFromWhitelist(address _address)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            isWhitelisted(_address),
            "Address is missing from the whitelist"
        );
        delete whitelist[_address];

        emit RemovedFromWhitelist(_address);
    }
}
