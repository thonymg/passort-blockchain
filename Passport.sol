import "github.com/Arachnid/solidity-stringutils/strings.sol";
import './OfficiersAccessControl.sol';

contract Passport is OfficiersAccessControl {
    using strings for *;
    struct Person {
        string personnalId;
        string firstName;
        string lastName;
        string occupation;
        uint _tempId;

        mapping(uint => LocalAdrress) location;
        mapping(uint => Caracter) caracters;
        mapping(uint => PassportDetails) passport;
        mapping(uint => Nation) nationality;
    }

    struct PassportDetails {
        string passportId;
        uint passportExpirationDate;
        uint passportDelivryDate;
        bool isAuthorized;
        address officierAddress;
    }

    struct LocalAdrress {
        string logNumber;
        string street;
        string city;
        string district;
        string state;
        string country;
    }

    struct Caracter {
        string tall;
        string eyeColor;
        string gender;
        string bornLocation;
        uint bornDate;
    }

    mapping(uint => Person) passportById;
    uint totalPassportCount = 0;

    // utility function

    function uintToString(uint v) internal constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }

    function createPersonnalId(uint8 _nationalityId) internal returns (string personnalId) {
        string _codeNation = passportById[totalPassportCount].nationality[_nationalityId].codeNation;
        string memory _count = uintToString(totalPassportCount);
        return (_codeNation.toSlice().concat(_count.toSlice()));
    }

    function addPerson(string _firstName, string _lastName, string _occupation) external {
        // make it required
        require( _firstName.toSlice().len() > 0);
        require( _lastName.toSlice().len() > 0);
        require( _occupation.toSlice().len() > 0);

        passportById[totalPassportCount] = Person('MG', _firstName, _lastName, _occupation, totalPassportCount);

        totalPassportCount++;
    }

    function addPersonLocation (
      uint _tempId,
      string _logNumber,
      string _street,
      string _city,
      string _district,
      string _state,
      string _country) internal onlyBureauOfficier() {
        // non null check
       require( _logNumber.toSlice().len() > 0);
       require( _street.toSlice().len() > 0);
       require( _city.toSlice().len() > 0);
       require( _district.toSlice().len() > 0);
       require( _state.toSlice().len() > 0);
       require( _country.toSlice().len() > 0);

       require(_tempId >= 0);


        passportById[_tempId].location[_tempId].logNumber = _logNumber;
        passportById[_tempId].location[_tempId].street = _street;
        passportById[_tempId].location[_tempId].city = _city;
        passportById[_tempId].location[_tempId].district = _district;
        passportById[_tempId].location[_tempId].state = _state;
        passportById[_tempId].location[_tempId].country = _country;
    }

    function addPersonCaracters(
      uint _tempId,
      string _tall,
      string _eyeColor,
      string _gender,
      string _bornLocation ,
      uint _bornDate) internal onlyBureauOfficier() {

        require( _tall.toSlice().len() > 0);
        require( _eyeColor.toSlice().len() > 0);
        require( _gender.toSlice().len() > 0);
        require( _bornLocation.toSlice().len() > 0);

        require( _bornDate > 0);
        require(_tempId >= 0);

       passportById[_tempId].caracters[_tempId].tall = _tall;
       passportById[_tempId].caracters[_tempId].eyeColor = _eyeColor;
       passportById[_tempId].caracters[_tempId].gender = _gender;
       passportById[_tempId].caracters[_tempId].bornLocation = _bornLocation;
       passportById[_tempId].caracters[_tempId].bornDate = _bornDate;
    }


    function addPersonNationality(uint _tempId, uint8 _nationId) internal {

        require(_tempId >= 0);
        require( _nationId > 0);

        passportById[_tempId].nationality[_tempId] = nationDetailsById[_nationId];
    }

    function addPassportDetails(uint _tempId) external onlyBureauOfficier() returns (bool isAuthorized) {

        passportById[_tempId].passport[_tempId].passportId = 'create a function to calculate this unique Id';
        passportById[_tempId].passport[_tempId].passportDelivryDate = now;
        passportById[_tempId].passport[_tempId].passportExpirationDate = now + (5 * 52 weeks);
        passportById[_tempId].passport[_tempId].isAuthorized = true;
        passportById[_tempId].passport[_tempId].officierAddress = msg.sender;

        return true;

    }

    function getPassportById(uint _passportId) public view returns (string firstName, string lastName, string occupation, uint _tempId) {
        return (passportById[_passportId].firstName,
                passportById[_passportId].lastName,
                passportById[_passportId].occupation,
                passportById[_passportId]._tempId );
    }

    function getPassportByIdLocation(uint _passportId)
      public view returns (string logNumber, string street, string city, string district, string state, string country){
        string _logNumber = passportById[_passportId].location[_passportId].logNumber;
        string _street = passportById[_passportId].location[_passportId].street;
        string _city = passportById[_passportId].location[_passportId].city;
        string _district = passportById[_passportId].location[_passportId].district;
        string _state = passportById[_passportId].location[_passportId].state;
        string _country = passportById[_passportId].location[_passportId].country;

        return (_logNumber, _street, _city, _district, _state, _country);
    }

    function getPassportByIdCaracters(uint _passportId)
      public view returns (string tall, string eyeColor, string gender, string bornLocation, uint bornDate){
        string _tall = passportById[_passportId].caracters[_passportId].tall;
        string _eyeColor = passportById[_passportId].caracters[_passportId].eyeColor;
        string _gender = passportById[_passportId].caracters[_passportId].gender;
        string _bornLocation = passportById[_passportId].caracters[_passportId].bornLocation;
        uint _bornDate = passportById[_passportId].caracters[_passportId].bornDate;

        return (_tall, _eyeColor, _gender, _bornLocation, _bornDate);
    }

    function getNationalityById(uint8 _nationId)
      public view returns (string codeNation, string nationName, string nationalityName, bool isUNNAtion) {
        return( nationDetailsById[_nationId].codeNation,
                nationDetailsById[_nationId].nationName,
                nationDetailsById[_nationId].nationalityName,
                nationDetailsById[_nationId].isUNNAtion );
    }
}