pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

//@dev not optimised for gas
contract Community is Initializable {
    using SafeMath for uint256;

    struct Report {
        string skylink;
        string resolvedSkylink;
        string title;
        string description;
        bool resolved;
        bool active;
        string receipt;
        string resolvedReceipt;
        string location;
    }
    mapping(string => Report) reports;
    string[] reportKeys;
    address owner;

    /*=======================================functions definition======================================= */
    function init() public initializer {
        require(msg.sender != address(0), "invalid sender");
        owner = msg.sender;
    }

    function report(
        string memory skylink,
        string memory title,
        string memory description,
        string memory location
    ) public {
        require(
            !reports[skylink].active && !reports[skylink].resolved,
            "already reported or resolved"
        );
        reports[skylink].title = title;
        reports[skylink].description = description;
        reports[skylink].skylink = skylink;
        reports[skylink].location = location;
        reports[skylink].active = true;
        reportKeys.push(skylink);
    }

    function addReceipt(string memory skylink, string memory receipt) public {
        require(reports[skylink].active, "Doesnt exist");
        reports[skylink].receipt = receipt;
    }

    function addReceiptResolved(string memory skylink, string memory receipt)
        public
    {
        require(reports[skylink].active, "Doesnt exist");
        reports[skylink].resolvedReceipt = receipt;
    }
    function resolveReport(string memory resolved_link, string memory report_id)
        public
    {
        require(
            reports[report_id].active && !reports[report_id].resolved,
            "already resolved"
        );
        reports[report_id].resolved = true;
        reports[report_id].resolvedSkylink = resolved_link;
    }

    function getReportKeys() public view returns (string[] memory) {
        return reportKeys;
    }

    function getReport(string memory id)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            bool
        )
    {
        return (
            reports[id].skylink,
            reports[id].title,
            reports[id].description,
            reports[id].resolvedSkylink,
            reports[id].receipt,
            reports[id].location,
            reports[id].resolved
        );
    }
    function getResolvedReceipt(string memory skyLink) public view returns({}
}
