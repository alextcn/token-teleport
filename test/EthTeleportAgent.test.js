const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = constants;

const ERC20Mock = artifacts.require('ERC20Mock');
const WrappedTokenMock = artifacts.require('WrappedTokenMock')
const EthTeleportAgent = artifacts.require('EthTeleportAgent');


contract('EthTeleportAgent', function (accounts) {
    const [sender, other] = accounts;

    const thisChainId = 31337;
    const anotherChainId = 56;
    const anotherChainTokenAddress = '0x433022c4066558e7a32d850f02d2da5ca782174d';

    const name = 'My Token';
    const symbol = 'MTKN';
    const tokenSupply = new BN(100);

    const anotherTokenSupply = new BN(100);

    const registerFee = new BN(500);
    const teleportFee = new BN(100);

    beforeEach(async function () {
        // deploy original token 
        this.token = await ERC20Mock.new();
        await this.token.initialize(name, symbol, 18, sender);
        await this.token.mint(tokenSupply);

        // deploy another token 
        this.anotherToken = await ERC20Mock.new();
        await this.anotherToken.initialize('Another Token', 'ATKN', 18, sender);
        await this.anotherToken.mint(anotherTokenSupply);

        // deploy wrapped token
        this.wrappedTokenMock = await WrappedTokenMock.new();
        await this.wrappedTokenMock.initialize('Wrapped Token', 'WTKN', 18, sender);

        // deploy teleport
        this.teleport = await EthTeleportAgent.new();
        await this.teleport.initialize(registerFee, teleportFee, sender, this.wrappedTokenMock.address);

        this.ownable = this.teleport;
    });

    describe('transfer ownership', function () {
        it('changes owner after transfer', async function () {
            const receipt = await this.teleport.transferOwnership(other, { from: sender });
            expectEvent(receipt, 'OwnershipTransferred');

            expect(await this.teleport.owner()).to.equal(other);
        });

        it('prevents non-owners from transferring', async function () {
            await expectRevert(
                this.teleport.transferOwnership(other, { from: other }),
                'Ownable: caller is not the owner',
            );
        });

        it('guards ownership against stuck state', async function () {
        await expectRevert(
            this.teleport.transferOwnership(ZERO_ADDRESS, { from: sender }),
            'Ownable: new owner is the zero address',
            );
        });
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
            await this.teleport.registerTeleportPair(tokenAddress, anotherChainId, { value: registerFee })
            expect(await this.teleport.routesFromTokenToChain_(tokenAddress, anotherChainId)).to.be.true;
        });
        it('anyone can register', async function () {
            const tokenAddress = this.token.address;
            await this.teleport.registerTeleportPair(tokenAddress, anotherChainId, { from: other, value: registerFee })
            expect(await this.teleport.routesFromTokenToChain_(tokenAddress, anotherChainId)).to.be.true;
        });
        it('can\'t register twice', async function () {
            const tokenAddress = this.token.address;
            await this.teleport.registerTeleportPair(tokenAddress, anotherChainId, { value: registerFee })
            expect(await this.teleport.routesFromTokenToChain_(tokenAddress, anotherChainId)).to.be.true;
            
            await expectRevert(
                this.teleport.registerTeleportPair(tokenAddress, anotherChainId, { value: registerFee }),
                'already registered'
            );
        });
        it('can\'t register non-contract', async function () {
            await expectRevert(
                this.teleport.registerTeleportPair(other, anotherChainId, { value: registerFee }),
                'given address is not a contract'
            );
        });
        it('fee is required', async function () {
            const tokenAddress = this.token.address;
            await expectRevert(
                this.teleport.registerTeleportPair(tokenAddress, anotherChainId),
                'fee mismatch'
            );
            await expectRevert(
                this.teleport.registerTeleportPair(tokenAddress, anotherChainId, { value: registerFee.sub(new BN(1)) }),
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

    describe('create teleport pair', function () {
        // - can create
        // - only owner
        // - can't create twice
        // - ...
    });

    describe('teleport start', function () {
        // - x
        // - y
    });

    describe('teleportFinish', function () {
        // - x
        // -
    });

    it('register, create, start', async function() {
        // register pair
        var receipt = await this.teleport.registerTeleportPair(
            this.token.address, 
            anotherChainId, 
            { value: registerFee }
        );
        expectEvent(receipt, 'TeleportPairRegistered');

        // create pair
        const fromChainId = thisChainId;
        const fromChainTokenAddr = this.token.address;
        const fromChainRegisterTxHash = receipt.tx;

        const originalTokenChainId = anotherChainId;
        const originalTokenAddr = this.anotherToken.address;

        const name = 'Wrapped Token';
        const symbol = 'WTKN';
        const decimals = 18;
        receipt = await this.teleport.createTeleportPair(
            fromChainId, fromChainTokenAddr, fromChainRegisterTxHash,
            originalTokenAddr, originalTokenChainId, 
            name, symbol, decimals
        );
        expectEvent(receipt, 'TeleportPairCreated');

        // check balance before
        expect(await this.token.balanceOf(sender)).to.be.bignumber.equal(tokenSupply);

        // start teleport
        const amount = new BN(5);
        await this.token.approve(this.teleport.address, amount);
        receipt = await this.teleport.teleportStart(
            this.token.address, amount, anotherChainId, 
            { value: teleportFee }
        );
        expectEvent(receipt, 'TeleportStarted');

        // check original token balance after teleport
        expect(await this.token.balanceOf(sender)).to.be.bignumber.equal(tokenSupply.sub(amount));
        expect(await this.token.balanceOf(this.teleport.address)).to.be.bignumber.equal(amount);

        // finish teleport (same chain for simplicity)
        const fromChainStartTxHash = receipt.tx;
        receipt = await this.teleport.teleportFinish(
            fromChainId, fromChainTokenAddr, fromChainStartTxHash,
            originalTokenChainId, originalTokenAddr,
            other, amount
        );
        expectEvent(receipt, 'TeleportFinished');

        // todo: check balance after
    });


});
