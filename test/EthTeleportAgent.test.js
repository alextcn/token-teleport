const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = constants;

const EthTeleportAgent = artifacts.require('EthTeleportAgent');

// TODO: 
// - set fixed fee values
// - deploy wrapped token
contract('EthTeleportAgent', function (accounts) {
    const [sender, other] = accounts;

    const registerFee = new BN(500);
    const teleportFee = new BN(100);

    beforeEach(async function () {
        // TODO: deploy wrapped token implementation
        const wrappedTokenImpl = ZERO_ADDRESS;

        this.teleport = await EthTeleportAgent.new();
        await this.teleport.initialize(registerFee, teleportFee, sender, wrappedTokenImpl);
    });

    it('has an owner', async function () {
        expect(await this.teleport.owner()).to.equal(sender);
    });

    describe('register fee', function () {
        it('is initialized', async function () {
            expect(await this.teleport.registerFee_()).to.be.bignumber.equal(registerFee);
        });

        const newRegisterFee = new BN(600);
        it('can set', async function () {    
            await this.teleport.setRegisterFee(newRegisterFee);
            expect(await this.teleport.registerFee_()).to.be.bignumber.equal(newRegisterFee);
        });
        it('reverts when set by not an owner', async function () {
            await expectRevert(
                this.teleport.setRegisterFee(newRegisterFee, { from: other }),
                'Ownable: caller is not the owner'
            );
        });
    });

    describe('teleport fee', function () {
        it('is initialized', async function () {
            expect(await this.teleport.teleportFee_()).to.be.bignumber.equal(teleportFee);
        });

        const newTeleportFee = new BN(150);
        it('can set', async function () {
            await this.teleport.setTeleportFee(newTeleportFee);
            expect(await this.teleport.teleportFee_()).to.be.bignumber.equal(newTeleportFee);
        });
        it('reverts when set by not an owner', async function () {
            await expectRevert(
                this.teleport.setTeleportFee(newTeleportFee, { from: other }),
                'Ownable: caller is not the owner'
            );
        });
    });

    describe('register teleport pair', function () {
        // todo: ...
    });

    describe('create teleport pair', function () {
        it('pair not created', async function () {
            // todo: ...
        });

        it('', async function () {
            // todo: ...
        });
    });

    describe('teleport start', function () {
        describe('fee not paid', function () {
            it('reverts', async function () {
                // call start teleport without msg.value less than teleportFee
            })
        });

        describe('pair not created', function () {
            it('reverts', async function () {
                // call start teleport
            })
        });

        describe('pair created', function () {
            // todo: ...
        });
    })

    describe('teleport finish', function () {
        // todo: ...
    });

});
