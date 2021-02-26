'use strict';

const { Contract } = require('fabric-contract-api');

class CustomerLoyalty extends Contract {

  // Init function executed when the ledger is instantiated
  async instantiate(ctx) {
    console.info('============= START : Initialize Ledger ===========');

    await ctx.stub.putState('instantiate', Buffer.from('INIT-LEDGER'));
    await ctx.stub.putState(earnPointsTransactionsKey, Buffer.from(JSON.stringify([])));
    console.info('============= END : Initialize Ledger ===========');
  }

  // Add a member on the ledger
  async CreateMember(ctx, member) {
    member = JSON.parse(member);

    await ctx.stub.putState(member.accountNumber, Buffer.from(JSON.stringify(member)));

    return JSON.stringify(member);
  }

}

module.exports = CustomerLoyalty;