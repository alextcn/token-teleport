const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = constants;

const { expect } = require('chai');

const BEP20OwnableMock = artifacts.require('contracts/mocks/BEP20TokenImplMocks.sol:OwnableMock');
const ERC20OwnableMock = artifacts.require('contracts/mocks/ERC20TokenImplMocks.sol:OwnableMock');
const EthTelOwnableMock = artifacts.require('contracts/mocks/EthTeleportAgentMocks.sol:OwnableMock');
const BscTelOwnableMock = artifacts.require('contracts/mocks/BscTeleportAgentMocks.sol:OwnableMock');

contract('ERC20Ownable', function (accounts) {
  shouldBehaveLikeOwnable(ERC20OwnableMock, accounts);
});

contract('BEP20Ownable', function (accounts) {
  shouldBehaveLikeOwnable(BEP20OwnableMock, accounts);
});

contract('EthTeleportAgentOwnable', function (accounts) {
  shouldBehaveLikeOwnable(EthTelOwnableMock, accounts);
});

contract('BscTeleportAgentOwnable', function (accounts) {
  shouldBehaveLikeOwnable(BscTelOwnableMock, accounts);
});


function shouldBehaveLikeOwnable(artifact, accounts) {
  const [ owner, other ] = accounts;

  beforeEach(async function () {
    this.ownable = await artifact.new({ from: owner });
  });

  it('has an owner', async function () {
    expect(await this.ownable.owner()).to.equal(owner);
  });

  describe('transfer ownership', function () {
    it('changes owner after transfer', async function () {
      const receipt = await this.ownable.transferOwnership(other, { from: owner });
      expectEvent(receipt, 'OwnershipTransferred');

      expect(await this.ownable.owner()).to.equal(other);
    });

    it('prevents non-owners from transferring', async function () {
      await expectRevert(
        this.ownable.transferOwnership(other, { from: other }),
        'Ownable: caller is not the owner',
      );
    });

    it('guards ownership against stuck state', async function () {
      await expectRevert(
        this.ownable.transferOwnership(ZERO_ADDRESS, { from: owner }),
        'Ownable: new owner is the zero address',
      );
    });
  });
}