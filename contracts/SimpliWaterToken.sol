pragma solidity ^0.4.18;
import "./helpers/CustomMintableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";

contract SimpliWaterToken is CustomMintableToken, BurnableToken {

    uint private dailyLimit; //1000 = 1L
    uint private penaltyChargePerLiter; //1000 = 1R
    uint private normalChargePerLiter; //1000 = 1R
    mapping(address => Meter) private registeredMeters;
    uint private constant ETHERIUM_TO_SWT_EXCHANGE_RATE = 2; // 1 ETH = 2 SWT for the sake of the proof of concept.

    struct Meter {
        address meterAddress;
        mapping(address => HouseMember) houseMembers;
        uint totalHouseMembers;
    }

    struct HouseMember {
        bytes16 firstName;
        bytes32 lastName;
        address memberAddress;
    }

    event MeterRegisteredEvent(address _meterAddress);
    event UserAddedEvent(address _meterAddress, address _memberAddress);
    

    function SimpliWaterToken() public {
        totalSupply_ = 0; // New coins will continuously be minted when needed.
        dailyLimit = 50000;
        penaltyChargePerLiter = 4000;
        normalChargePerLiter = 1000;
    }
   
    function registerMeter(address _meterAddress) onlyOwner public {
        require(registeredMeters[_meterAddress].meterAddress == address(0));
        var newMeter = Meter({meterAddress: _meterAddress, totalHouseMembers:0});
        registeredMeters[_meterAddress] = newMeter;
        MeterRegisteredEvent(_meterAddress);
    }

    function retrieveMeterHouseMemberTotal(address _meterAddress) onlyOwner view public returns(address meterAddress, uint totalHouseMembers) {
        require(registeredMeters[_meterAddress].meterAddress != address(0));
        return (registeredMeters[_meterAddress].meterAddress, registeredMeters[_meterAddress].totalHouseMembers);
    }

   function addUserToMeter(address _meterAddress, bytes16 _firstName, bytes16 _lastName, address _memberAddress) onlyOwner public {
        require(registeredMeters[_meterAddress].meterAddress != address(0));
        require(registeredMeters[_meterAddress].houseMembers[_memberAddress].memberAddress == address(0));        
        var newMember = HouseMember(_firstName, _lastName, _memberAddress);
        registeredMeters[_meterAddress].houseMembers[_memberAddress] = newMember;
        registeredMeters[_meterAddress].totalHouseMembers += 1;
        UserAddedEvent(_meterAddress, _memberAddress);
    }

    function setDailyLimit(uint _dailyLimit) onlyOwner public {
        dailyLimit = _dailyLimit;
    }

   function getDailyLimit() view public returns(uint _dailyLimit) {
        return dailyLimit;
    }

    function setPenaltyChargePerLiter(uint _penaltyCharge) onlyOwner public {
        penaltyChargePerLiter = _penaltyCharge;
    }

   function getPenaltyChargePerLiter() view public returns (uint penaltyCharge) {
        return penaltyChargePerLiter;
    }

    function setNormalChargePerLiter(uint _normalCharge) onlyOwner public {
        normalChargePerLiter = _normalCharge;
    }

    function getNormalChargePerLiter() view public returns(uint _normalCharge) {
        return normalChargePerLiter;
    }

    function topUpBalance(address _meterAddress, uint _value) onlyOwner public {
        topUp(_meterAddress, _value);
    }

    function topUp(address _meterAddress, uint _value) private {
        require(registeredMeters[_meterAddress].meterAddress != address(0));
        mint(_meterAddress, _value);    
    }

    function burn(uint _tokensToBurn) public {
        require(registeredMeters[msg.sender].meterAddress != address(0));
        require(balances[msg.sender] >= _tokensToBurn);
        super.burn(_tokensToBurn);
    }

    function topUpBalanceWithEther(address _meterAddress, uint _value) payable public {
        topUp(_meterAddress, _value);
    }


    function getTokenBalance(address _meterAddress) view public returns(uint) {
    return balances[_meterAddress];
    }

    function getEthBalance(address _meterAddress) view public returns(uint) {
    return _meterAddress.balance;
    }

   }