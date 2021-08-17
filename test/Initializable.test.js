const { expectRevert } = require('@openzeppelin/test-helpers');

const { assert } = require('chai');

const BEP20InitializableMock = artifacts.require('contracts/mocks/BEP20TokenImplMocks.sol:InitializableMock');
const ERC20InitializableMock = artifacts.require('contracts/mocks/ERC20TokenImplMocks.sol:InitializableMock');
const EthTelInitializableMock = artifacts.require('contracts/mocks/EthTeleportAgentMocks.sol:InitializableMock');
const BscTelInitializableMock = artifacts.require('contracts/mocks/BscTeleportAgentMocks.sol:InitializableMock');


contract('BEP20Initializable', function (accounts) {
  shouldBehaveLikeInitializable(BEP20InitializableMock);
});

contract('ERC20Initializable', function (accounts) {
  shouldBehaveLikeInitializable(ERC20InitializableMock);
});

contract('EthTeleportAgentInitializable', function (accounts) {
  shouldBehaveLikeInitializable(EthTelInitializableMock);
});

contract('BscTeleportAgentInitializable', function (accounts) {
  shouldBehaveLikeInitializable(BscTelInitializableMock);
});


function shouldBehaveLikeInitializable(artifact) {
  describe('basic testing without inheritance', function () {
    beforeEach('deploying', async function () {
      this.contract = await artifact.new();
    });

    context('before initialize', function () {
      it('initializer has not run', async function () {
        assert.isFalse(await this.contract.initializerRan());
      });
    });

    context('after initialize', function () {
      beforeEach('initializing', async function () {
        await this.contract.initialize();
      });

      it('initializer has run', async function () {
        assert.isTrue(await this.contract.initializerRan());
      });

      it('initializer does not run again', async function () {
        await expectRevert(this.contract.initialize(), 'Initializable: contract is already initialized');
      });
    });

    context('after nested initialize', function () {
      beforeEach('initializing', async function () {
        await this.contract.initializeNested();
      });

      it('initializer has run', async function () {
        assert.isTrue(await this.contract.initializerRan());
      });
    });
  });
}