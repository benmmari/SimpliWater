var SimplyWaterToken = artifacts.require('./SimpliWaterToken.sol');

contract('SimpliWaterToken', function (accounts) {
   let contract;
   const admin = accounts[0];
   const meter = accounts[1];      
   const user_1 = accounts[2];      
   const user_2 = accounts[3];      
   const user_3 = accounts[4];   

   //TODO: Implement test that cause exceptions.

    before(async function(){
        contract = await SimplyWaterToken.deployed();   
      });

      it("Total supply set to zero", async function() {
        let returnedTotalSupply = await contract.totalSupply();
        assert.equal(returnedTotalSupply, 0);
      });

      it("Owner can set daily limit", async function() {
        await contract.setDailyLimit(87000);
        let returnedDailyLimit = await contract.getDailyLimit();
        assert.equal(returnedDailyLimit, 87000);
      });


      it("Owner can set penalty charge", async function() {
        await contract.setPenaltyChargePerLiter(100);
        let returnedPenaltyChargePerLiter = await contract.getPenaltyChargePerLiter();
        assert.equal(returnedPenaltyChargePerLiter, 100);
      });


      it("Owner can set normal charge", async function() {
        await contract.setNormalChargePerLiter(300);
        let returnedPenaltyChargePerLiter = await contract.getNormalChargePerLiter();
        assert.equal(returnedPenaltyChargePerLiter, 300);
      });

      it("Owner can register meter with 0 users", async function() {
        await contract.registerMeter(meter);
        let returnedMeter = await contract.retrieveMeterHouseMemberTotal(meter);
        assert.equal(returnedMeter[0], meter);
        assert.equal(returnedMeter[1], 0);        
      });

      it("Owner can add user to meter", async function() {
        let testUserFirstName = "Satoshi";
        let testUserLastName = "Nakomoto";
        let testUserAccount = user_1;
        
        await contract.addUserToMeter(meter, testUserFirstName, testUserLastName, testUserAccount);
        let returnedMeter = await contract.retrieveMeterHouseMemberTotal(meter);
        assert.equal(returnedMeter[0], meter);
        assert.equal(returnedMeter[1], 1);        
      });


      it("Owner can top up meter balance by an arbitrary amount", async function() { 
        let topUpAmount = 1000;      
        let meterBalanceBefore = await contract.balanceOf(meter);  
        await contract.topUpBalance(meter, topUpAmount);
        let meterBalanceAfter = await contract.balanceOf(meter); 
        assert.equal(parseInt(meterBalanceAfter), parseInt(meterBalanceBefore) + parseInt(topUpAmount));
      });


      it("Meter can burn an arbitrary amount", async function() { 
        let burnAmount = 500;      
        let meterBalanceBefore = await contract.balanceOf(meter);  
        await contract.burn(burnAmount, {from: meter});
        let meterBalanceAfter = await contract.balanceOf(meter); 
        assert.equal(parseInt(meterBalanceAfter), parseInt(meterBalanceBefore) - parseInt(burnAmount));
      });


      it("An arbitrary accountholder can send ether and top up the meter balance an arbitrary amount", async function() { 
        let topUpAmount = 5000;      
        let weiValue = 10;
        let contractBalanceBefore = await contract.getEthBalance(meter); 
        let meterBalanceBefore = await contract.balanceOf(meter);  
        await contract.topUpBalanceWithEther(meter, topUpAmount, {value:weiValue, from: user_1});
        let meterBalanceAfter = await contract.balanceOf(meter); 
        let contractBalanceAfter = await contract.getEthBalance(meter);        
        assert.equal(parseInt(meterBalanceAfter), parseInt(meterBalanceBefore) + parseInt(topUpAmount));
        assert.equal(parseInt(contractBalanceBefore), parseInt(contractBalanceAfter) + parseInt(weiValue));       
      });
});