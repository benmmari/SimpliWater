pragma solidity ^0.4.18;
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";

contract SimplyWaterToken is MintableToken, BurnableToken {

    uint dailyLimit;
    uint penaltyChargePerLiter;
    uint normalChargePerLiter;
    mapping(address => Meter) registeredMeters;
    uint constant ETHERIUM_TO_SWT_EXCHANGE_RATE = 2;

    struct Meter {
        address meterAddress;
        mapping(address => HouseMember) houseMembers;
    }

    struct HouseMember {
        bytes16 firstName;
        bytes32 lastName;
        address memberAddress;
    }

    function SimplyWaterToken() public {
        totalSupply_ = 0; //there is no total supply. New coins will continuously be minted.
    }
   
    function registerMeter(address _meterAddress) onlyOwner public {
        require(registeredMeters[_meterAddress].meterAddress == address(0));
        var newMeter = Meter({meterAddress: _meterAddress});
        registeredMeters[_meterAddress] = newMeter;
    }

   function addUserToMeter(address _meterAddress, bytes16 _firstName, bytes16 _lastName, address _memberAddress) onlyOwner public {
        require(registeredMeters[_meterAddress].meterAddress != address(0));
        var newMember = HouseMember(_firstName, _lastName, _memberAddress);
        registeredMeters[_meterAddress].houseMembers[_memberAddress] = newMember;
    }

    function setDailyLimit(uint _dailyLimit) onlyOwner public {
        dailyLimit = _dailyLimit;
    }

    function setPenaltyChargePerLiter(uint _penaltyCharge) onlyOwner public {
        penaltyChargePerLiter = _penaltyCharge;
    }

    function setNormalChargePerLiter(uint _normalCharge) onlyOwner public {
        normalChargePerLiter = _normalCharge;
    }

    function topUpBalance(address _meterAddress, uint value) onlyOwner public {
        require(registeredMeters[_meterAddress].meterAddress != address(0));
        mint(_meterAddress, value);    
    }

    function burn(uint tokensToBurn) public {
        require(registeredMeters[msg.sender].meterAddress != address(0));
        require(balances[msg.sender] >= tokensToBurn);
        super.burn(tokensToBurn);
    }

    function topUpBalanceWithEther(address _meterAddress, uint value) payable public {
        topUpBalance(_meterAddress, value);
    }
   }