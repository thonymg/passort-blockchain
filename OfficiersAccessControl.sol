import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./BaseAccesControl.sol";

contract OfficiersAccessControl is BaseAccesControl {
    using strings for *;

    struct Officier {
        string personnalId;
        string firstName;
        string lastName;
        address offierAddress;
        uint8 authorizationLevel;
        uint bureauId;
        bool inActivity;
    }

    struct Bureau {
        uint bureauId;
        string bureauLocation;
        string bureauCountry;
        uint8 bureauAuthorisationLevel;
        bool isInActivity;
        address[] bureauOfficiersAddress;
        address[] bureauAdminAddress;
    }

    struct Nation {
        string codeNation;
        string nationName;
        string nationalityName;
        bool isUNNAtion;
    }

    mapping(address => uint) bureauIdByAddress;
    mapping(address => Officier) officierByAddress;
    mapping(uint => Bureau) bureauById;
    mapping(uint8 => Nation) nationDetailsById;

    uint totalBureauCount = 0;
    uint8 totalNationCount = 0;

    function createNationDetails(string _codeNation, string _nationName, string _nationalityName, bool _isUNNAtion) internal onlyCaptain() returns(bool) {
        require( _codeNation.toSlice().len() > 0);
        require( _nationName.toSlice().len() > 0);
        require( _nationalityName.toSlice().len() > 0);

        // check if nation are allready set
        for (uint8 i = 0; i < totalNationCount; i ++) {
            if ( keccak256(nationDetailsById[i].codeNation ) == keccak256(_codeNation)
                || keccak256(nationDetailsById[i].nationName ) == keccak256(_nationName)
            ) {
                return false;
            }
        }

        nationDetailsById[totalNationCount].codeNation = _codeNation;
        nationDetailsById[totalNationCount].nationName = _nationName;
        nationDetailsById[totalNationCount].nationalityName = _nationalityName;
        nationDetailsById[totalNationCount].isUNNAtion = _isUNNAtion;

        totalNationCount++;
    }

    function addOfficier(address _officierAddress, string _firstName, string _lastName, uint8 _authorizationLevel) internal onlyBureauAdmin() {

        officierByAddress[_officierAddress].offierAddress = _officierAddress;
        officierByAddress[_officierAddress].firstName = _firstName;
        officierByAddress[_officierAddress].lastName = _lastName;
        officierByAddress[_officierAddress].authorizationLevel = _authorizationLevel;
        officierByAddress[_officierAddress].inActivity = true;

        // add new officier tocurrent bureau address
        officierByAddress[_officierAddress].bureauId = bureauIdByAddress[msg.sender];
        bureauById[bureauIdByAddress[msg.sender]].bureauOfficiersAddress.push(_officierAddress);
        bureauIdByAddress[_officierAddress] =  bureauIdByAddress[msg.sender];
    }

    function addEmptyBureau(string _bureauLocation, string _bureauCountry, uint8 _bureauAuthorisationLevel) internal onlyLieutnant() {
        bureauById[totalBureauCount].bureauId = totalBureauCount;
        bureauById[totalBureauCount].bureauLocation = _bureauLocation;
        bureauById[totalBureauCount].bureauCountry = _bureauCountry;
        bureauById[totalBureauCount].bureauAuthorisationLevel = _bureauAuthorisationLevel;
        bureauById[totalBureauCount].isInActivity = false;
        bureauById[totalBureauCount].bureauAdminAddress.push(msg.sender);

        totalBureauCount++;
    }

    function addAdminToBureau(address _adminAdress, uint _bureauId, string _bureauLocation) internal onlyBureauAdmin() {
        require(keccak256(bureauById[_bureauId].bureauLocation) == keccak256(_bureauLocation));
        bureauById[_bureauId].bureauAdminAddress.push(_adminAdress);
        bureauIdByAddress[_adminAdress] = _bureauId;
    }

    modifier onlyBureauAdmin() {
        address[] memory adminAddress = bureauById[bureauIdByAddress[msg.sender]].bureauAdminAddress;
        bool isAnAdminAdress;
        for(uint i; i < adminAddress.length; i++) {
            if(msg.sender == adminAddress[i]) {
                isAnAdminAdress = true;
                break;
            }
            isAnAdminAdress = false;
        }

        require(isAnAdminAdress == true);
        _;
    }

    modifier onlyBureauOfficier() {
        address[] memory officierAddress = bureauById[bureauIdByAddress[msg.sender]].bureauOfficiersAddress;
        bool isAnOfficierAddress;
        for(uint i; i < officierAddress.length; i++) {
            if(msg.sender == officierAddress[i]) {
                isAnOfficierAddress = true;
                break;
            }
            isAnOfficierAddress = false;
        }

        require(isAnOfficierAddress == true);
        _;
    }

    modifier bureauAuthLevel(uint8 _authLevel) {
        require(bureauById[bureauIdByAddress[msg.sender]].bureauAuthorisationLevel >= _authLevel);
        _;
    }

    modifier officierAuthLevel(uint8 _authLevel) {
        require(officierByAddress[msg.sender].authorizationLevel >= _authLevel);
        _;
    }
}
