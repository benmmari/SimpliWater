var SimplyWaterToken = artifacts.require('./SimplyWaterToken.sol');

contract('SimplyWaterToken', function (accounts) {
    let contract;
    const admin = accounts[0];
    const meter = accounts[1];

    before(async function(){
        contract = await SimplyWaterToken.deployed();
      });


      it("Total supply set to zero", async function() {
        var returnedTotalSupply = await contract.totalSupply();
        assert.equal(returnedTotalSupply, 0);
      });

});