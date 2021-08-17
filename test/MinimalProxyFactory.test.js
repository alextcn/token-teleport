const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

const shouldBehaveLikeClone = require('./MinimalProxyFactory.behaviour');

const MinimalProxyFactory = artifacts.require('MinimalProxyFactory');

contract('MinimalProxyFactory', function (accounts) {
  describe('clone', function () {
    shouldBehaveLikeClone(async (implementation, initData, opts = {}) => {
      const factory = await MinimalProxyFactory.new();
      const receipt = await factory.deploy(implementation, initData);
      // const receipt = await factory.deploy(implementation, initData, { value: opts.value });
      const address = receipt.logs.find(({ event }) => event === 'ProxyDeployed').args.proxy;
      // console.log('deployed to address:', address);
      return { address };
    });
  });
});
