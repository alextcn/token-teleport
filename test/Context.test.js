const { BN, expectEvent } = require('@openzeppelin/test-helpers');

const ERC20ContextMock = artifacts.require('contracts/mocks/ERC20TokenImplMocks.sol:ContextMock');
const ERC20ContextMockCaller = artifacts.require('contracts/mocks/ERC20TokenImplMocks.sol:ContextMockCaller');
const BEP20ContextMock = artifacts.require('contracts/mocks/BEP20TokenImplMocks.sol:ContextMock');
const BEP20ContextMockCaller = artifacts.require('contracts/mocks/BEP20TokenImplMocks.sol:ContextMockCaller');
const EthTeleportAgentContextMock = artifacts.require('contracts/mocks/EthTeleportAgentMocks.sol:ContextMock');
const EthTeleportAgentContextMockCaller = artifacts.require('contracts/mocks/EthTeleportAgentMocks.sol:ContextMockCaller');
const BscTeleportAgentContextMock = artifacts.require('contracts/mocks/BscTeleportAgentMocks.sol:ContextMock');
const BscTeleportAgentContextMockCaller = artifacts.require('contracts/mocks/BscTeleportAgentMocks.sol:ContextMockCaller');


contract('ERC20Context', function (accounts) {
  shouldBehaveLikeRegularContext(ERC20ContextMock, ERC20ContextMockCaller, accounts);
});

contract('BEP20Context', function (accounts) {
  shouldBehaveLikeRegularContext(BEP20ContextMock, BEP20ContextMockCaller, accounts);
});

contract('EthTeleportAgentContext', function (accounts) {
  shouldBehaveLikeRegularContext(EthTeleportAgentContextMock, EthTeleportAgentContextMockCaller, accounts);
});

contract('BscTeleportAgentContext', function (accounts) {
  shouldBehaveLikeRegularContext(BscTeleportAgentContextMock, BscTeleportAgentContextMockCaller, accounts);
});


function shouldBehaveLikeRegularContext (contextArtifact, contextCallerArtifact, accounts) {
  const [ sender ] = accounts;

  beforeEach(async function () {
    this.context = await contextArtifact.new();
    this.caller = await contextCallerArtifact.new();
  });

  describe('msgSender', function () {
    it('returns the transaction sender when called from an EOA', async function () {
      const { logs } = await this.context.msgSender({ from: sender });
      expectEvent.inLogs(logs, 'Sender', { sender });
    });

    it('returns the transaction sender when from another contract', async function () {
      const { tx } = await this.caller.callSender(this.context.address, { from: sender });
      await expectEvent.inTransaction(tx, contextArtifact, 'Sender', { sender: this.caller.address });
    });
  });

  describe('msgData', function () {
    const integerValue = new BN('42');
    const stringValue = 'OpenZeppelin';

    let callData;

    beforeEach(async function () {
      callData = this.context.contract.methods.msgData(integerValue.toString(), stringValue).encodeABI();
    });

    it('returns the transaction data when called from an EOA', async function () {
      const { logs } = await this.context.msgData(integerValue, stringValue);
      expectEvent.inLogs(logs, 'Data', { data: callData, integerValue, stringValue });
    });

    it('returns the transaction sender when from another contract', async function () {
      const { tx } = await this.caller.callData(this.context.address, integerValue, stringValue);
      await expectEvent.inTransaction(tx, contextArtifact, 'Data', { data: callData, integerValue, stringValue });
    });
  });
}
