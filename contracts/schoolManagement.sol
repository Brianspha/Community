pragma solidity >=0.5.0;
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
pragma experimental ABIEncoderV2;

/*
*@dev contract definition
@notice not optimised for gas 
 */

contract schoolManagement is Initializable {
    using SafeMath for uint256;
    /*=======================================events definition======================================= */
    event school_registered(bool indexed registered);
    event logged_request(bool indexed logged);
    event request_resolved(bool indexed resolved);
    /*=======================================structs definition======================================= */
    struct School {
        address id;
        string name;
        string province;
        address principle_id;
        bytes32[] resolved_requests;
        bytes32[] requested;
        bool active;
    }
    struct Request {
        bytes32 id;
        string skynet_link;
        string resolve_skynet_link;
        address school_id;
        address resolved_by;
        bool resolved;
        bool active;
    }

    struct Principle {
        address id;
        bool active;
    }
    struct Official {
        address id;
        bool active;
    }
    /*=======================================modifiers definition======================================= */
    modifier registeredPrinciple() {
        require(
            msg.sender != address(0) && school_principles[msg.sender].active,
            "Principel not registered"
        );
        _;
    }
    modifier registeredSchool(address school_id) {
        require(
            school_id != address(0) && registered_schools[school_id].active,
            "School not active"
        );
        _;
    }
    modifier activeRequest(bytes32 id) {
        require(
            pending_requests[id].active && !pending_requests[id].resolved,
            "Query not active"
        );
        _;
    }
    modifier registeredOfficial() {
        require(
            registered_officials[msg.sender].active,
            "Official not registered"
        );
        _;
    }
    /*=======================================mappings definition======================================= */
    mapping(bytes32 => Request) pending_requests;
    mapping(address => Principle) school_principles;
    mapping(address => School) registered_schools;
    mapping(address => Official) registered_officials;
    /*=======================================arrays definition======================================= */
    bytes32[] resolved_requests_keys;
    bytes32[] pending_requests_keys;
    address[] school_principle_keys;
    address[] registered_schools_keys;
    address[] registered_officials_keys;
    /*=======================================const definition======================================= */
    address owner;

    /*=======================================functions definition======================================= */
    function init() public initializer {
        require(msg.sender != address(0), "invalid sender");
        owner = msg.sender;
    }

    function registerSchool(
        string memory name,
        string memory province,
        address school_id
    ) public {
        require(
            msg.sender != address(0) && school_id != address(0),
            "invalid principle and or school address"
        );
        require(
            !registered_schools[school_id].active,
            "school already registered"
        );
        require(
            !school_principles[msg.sender].active,
            "principle already registered"
        );
        registered_schools[school_id].name = name;
        registered_schools[school_id].province = province;
        registered_schools[school_id].principle_id = school_id;
        registered_schools[school_id].active = true;
        school_principles[msg.sender].id = msg.sender;
        school_principles[msg.sender].active=true;
        registered_schools_keys.push(school_id);
        school_principle_keys.push(msg.sender); //@dev bad design but owell!!! :XD
        emit school_registered(true);
    }

    function getRegisteredSchoolKeys() public view returns (address[] memory) {
        return registered_schools_keys;
    }

    function getSchool(address id)
        public
        view
        returns (
            string memory,
            string memory,
            address,
            bytes32[] memory,
            bytes32[] memory
        )
    {
        return (
            registered_schools[id].name,
            registered_schools[id].province,
            registered_schools[id].principle_id,
            registered_schools[id].resolved_requests,
            registered_schools[id].requested
        );
    }

    function logRequest(string memory skynet_link, address school_id)
        public
        registeredPrinciple
        registeredSchool(school_id)
    {
        bytes32 id = keccak256(abi.encodePacked(skynet_link, school_id, now));
        require(!pending_requests[id].active, "Request logged");
        pending_requests[id].id = id;
        pending_requests[id].school_id = school_id;
        pending_requests[id].resolved = false;
        pending_requests[id].active = true;
        pending_requests_keys.push(id);
        emit logged_request(true);
    }

    function getRequestedKeys() public view returns (bytes32[] memory) {
        return pending_requests_keys;
    }

    function getRequestedDetails(bytes32 id)
        public
        view
        returns (
            string memory,
            address,
            bool,
            bool
        )
    {
        return (
            pending_requests[id].skynet_link,
            pending_requests[id].school_id,
            pending_requests[id].resolved,
            pending_requests[id].active
        );
    }

    function registerOfficial() public {
        require(msg.sender != address(0), "invalid official address");
        registered_officials[msg.sender].id = msg.sender;
        registered_officials[msg.sender].active = true;
        registered_officials_keys.push(msg.sender);
    }

    function getOfficialKeys() public view returns (address[] memory) {
        return registered_officials_keys;
    }

    function getOfficial(address id) public view returns (bool) {
        return registered_officials[id].active;
    }

    function updateLogRequest(bytes32 id, string memory skylink_desription)
        public
        activeRequest(id)
        registeredOfficial()
    {
        pending_requests[id].resolved = true;
        pending_requests[id].resolved_by = msg.sender;
        pending_requests[id].resolve_skynet_link = skylink_desription;
        resolved_requests_keys.push(id);
        emit request_resolved(true);
    }
}
