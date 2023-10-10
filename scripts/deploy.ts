import { ethers, upgrades } from 'hardhat';

async function main() {
  const avatharAdmin = '';

  const baseUri = 'https://arweave.net/';

  const CallIt = await ethers.getContractFactory('OpinionTrading');
  const callIt = await upgrades.deployProxy(CallIt, [avatharAdmin, baseUri], {
    timeout: 40000,
    pollingInterval: 4000,
    kind: 'uups',
  });

  await callIt.deployed();

  console.log('callIt Address:', callIt.address);
}
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
