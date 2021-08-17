const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = constants;

const ERC20Mock = artifacts.require('ERC20Mock');
const EthTeleportAgent = artifacts.require('EthTeleportAgent');


contract('EthTeleportAgent', function (accounts) {
    const [sender, other] = accounts;

    const name = 'My Token';
    const symbol = 'MTKN';

    const registerFee = new BN(500);
    const teleportFee = new BN(100);

    beforeEach(async function () {
        // deploy token 
        this.token = await ERC20Mock.new();
        const x = await this.token.initialize(name, symbol, 18, sender);

        // todo: deploy wrapped token implementation
        const wrappedTokenImpl = ZERO_ADDRESS;

        // deploy teleport
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
        it('can register by owner', async function () {
            const tokenAddress = this.token.address;
            const chainId = 56;
            await this.teleport.registerTeleportPair(tokenAddress, chainId, { value: registerFee })
            expect(await this.teleport.routesFromTokenToChain_(tokenAddress, chainId)).to.be.true;
        });
        it('anyone can register', async function () {
            const tokenAddress = this.token.address;
            const chainId = 56;
            await this.teleport.registerTeleportPair(tokenAddress, chainId, { from: other, value: registerFee })
            expect(await this.teleport.routesFromTokenToChain_(tokenAddress, chainId)).to.be.true;
        });
        it('can\'t register twice', async function () {
            const tokenAddress = this.token.address;
            const chainId = 56;
            await this.teleport.registerTeleportPair(tokenAddress, chainId, { value: registerFee })
            expect(await this.teleport.routesFromTokenToChain_(tokenAddress, chainId)).to.be.true;
            
            await expectRevert(
                this.teleport.registerTeleportPair(tokenAddress, chainId, { value: registerFee }),
                'already registered'
            );
        });
        it('can\'t register non-contract', async function () {
            await expectRevert(
                this.teleport.registerTeleportPair(other, 56, { value: registerFee }),
                'given address is not a contract'
            );
        });
        it('fee is required', async function () {
            const tokenAddress = this.token.address;
            await expectRevert(
                this.teleport.registerTeleportPair(tokenAddress, 56),
                'fee mismatch'
            );
            await expectRevert(
                this.teleport.registerTeleportPair(tokenAddress, 56, { value: registerFee.sub(new BN(1)) }),
                'fee mismatch'
            );
        });
        xit('can\'t register for this chain', async function () {
            const chainId = 1; // todo: get current network id
            await expectRevert(
                this.teleport.registerTeleportPair(this.token.address, chainId, { value: registerFee }),
                'no need to register teleport to original chain'
            );
        })
    });

    xdescribe('create teleport pair', function () {
        it('pair not created', async function () {
            // todo: ...
        });

        it('', async function () {
            // todo: ...
        });
    });

    xdescribe('teleport start', function () {
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

    xdescribe('teleport finish', function () {
        // todo: ...
    });

});
