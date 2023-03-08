import wevmosAbi from "./ABI/wevmos.json";
import atomAbi from "./ABI/atom.json";
import usdcAbi from "./ABI/usdc.json";
import diaAbi from "./ABI/dia.json";
import wethAbi from "./ABI/weth.json";
import oracleAbi from "./ABI/oracle.json";
import egoAbi from "./ABI/ego.json";
import vstableAbi from "./ABI/stablevault.json";
import vliquidAbi from "./ABI/liquidvault.json";
import { IContracts } from "./types";
import { chainId } from "wagmi";

import tokenAbi from "./ABI/4002/token.json";
import vaultAbi from "./ABI/4002/vault.json";
import strategyAbi from "./ABI/4002/strategy.json";
import entrypointAbi from "./ABI/4002/entrypoint.json";
import trusteeAbi from "./ABI/4002/trustee.json";
import personaAbi from "./ABI/4002/personalization.json";
import priceFeedAbi from "./ABI/4002/pricefeedconsumer.json";

export const contracts: IContracts = {
  9000: {
    WEVMOS: {
      address: "0x67f54b40FaCcA8FB38B68b28578a7AC0D9Ffb0f3",
      abi: wevmosAbi,
    },
    USDC: {
      address: "0x72c91eD03b71694Cd5C08c01eFc504311D60d76d",
      abi: usdcAbi,
    },
    USDT: {
      address: "0x3369B66Cc041132f596317830ae36B91FAAC9e53",
      abi: usdcAbi,
    },
    BUSD: {
      address: "0xCD65d9e43151CFdf2173F45a4B10A1F0ecD901D2",
      abi: usdcAbi,
    },
    DAI: {
      address: "0x9c18C4b97452828Ad4040EBaEca1aF32B099F863",
      abi: usdcAbi,
    },
    FRAX: {
      address: "0xA2d7F7680121F99666F5154F2D4C1E26c8B59975",
      abi: usdcAbi,
    },
    ATOM: {
      address: "0xDF7d1005A3E427AEE0A78bC5192778146E998FeF",
      abi: atomAbi,
    },
    WETH: {
      address: "0x759C1d32865617E0dF2044888C9c8e07Bd6d5EbD",
      abi: wethAbi,
    },
    DIA: { address: "0x8D3F60D7689A23570ebB08C1552dcbF5Cb949e8d", abi: diaAbi },
    ORACLE: {
      address: "0xC1cd21E2a659aB7Ca56331693748d20b441BA621",
      abi: oracleAbi,
    },
    STABLEV: {
      address: "0xB59D3fB912F860fDf268A60e3b9Edad7E9F3e501",
      abi: vstableAbi,
    },
    LIQUIDV: {
      address: "0x9e072184b7C5680066FF6A042f151eb5A52FA8e9",
      abi: vliquidAbi,
    },
    EGO: { address: "0x56B5b64675FCf880fb1385E97A81137d6bA1A3e0", abi: egoAbi },
  },
  4002: {
    STRATEGY: {
      address: "0x93231c5bB4dc64D997B796E3ed3818067a9BcDFc",
      abi: strategyAbi,
    },
    ENTRYPOINT: {
      address: "0x94E978c94684C13A58Cd98b108E07048412ffB7f",
      abi: entrypointAbi,
    },
    ORACLE: {
      address: "0xe1DefDa5c6aC3A9530d1cF07Cc52fe3384117141",
      abi: priceFeedAbi,
    },
    PERSONALIZATION: {
      address: "0x7d2A8eE65f1726cc2E37eB12f0b434fa8649030C",
      abi: personaAbi,
    },
    TRUSTEE: {
      address: "0xAfC9Bd0eFBb983a6CFbD42714789F7b8b7870645",
      abi: trusteeAbi,
    },
    // VAULTS: {
    //   address: [
    //     "0xc2C551cbDAFDB3585f415cFB3672Ebefc87f8D50", //dai
    //     "0x2e2171CBe9304A25AC7D73ea96DB02D96734575b", //usdc
    //     "0x132E6E29bD310f78bd63d8E3353E3e1040817cc1", //usdt
    //     "0xf04C0Cc8cFD4336b7f1f871D4D25Ea7241c08e2D", //wftm
    //     "0x524e20EbE1CB9a48c3B1CCb4C10680AE1510fF52", //weth
    //   ],
    //   abi: vaultAbi,
    // },
    // TOKENS: {
    //   address: [
    //     "0x962905C1a51FEa5F7aF859fDA531E45CC782E633", //dai
    //     "0xD8323CDac86c25D558A51700d88E39Ca0Cef93c0", //usdc
    //     "0x46EF3F37F02d1EDB4323893f9572bAc5b2f51A5f", //usdt
    //     "0x41ff6593cb7A3108ceF7E3047c24FD8AfDCADaAD", //wftm
    //     "0x05D82aCaBFa06Ebf60F6e8fD407b8E2640a7A883", //weth
    //   ],
    //   abi: tokenAbi,
    // },
  },
};

// export const tokens = (chainId: string | number) => [
//   { name: "DAI", decimals: 18, ...contracts[chainId].TOKENS.address[0] },
//   { name: "USDC", decimals: 6, ...contracts[chainId].TOKENS.address[1] },
//   { name: "USDT", decimals: 6, ...contracts[chainId].TOKENS.address[2] },
//   { name: "WFTM", decimals: 18, ...contracts[chainId].TOKENS.address[3] },
//   { name: "WETH", decimals: 18, ...contracts[chainId].TOKENS.address[4] },
// ];

// export const vaults = (chainId: string | number) => [
//   { name: "svDAI", decimals: 18, ...contracts[chainId].VAULTS.address[0] },
//   { name: "svUSDC", decimals: 6, ...contracts[chainId].VAULTS.address[1] },
//   { name: "svUSDT", decimals: 6, ...contracts[chainId].VAULTS.address[2] },
//   { name: "lvFTM", decimals: 18, ...contracts[chainId].VAULTS.address[3] },
//   { name: "lvWETH", decimals: 18, ...contracts[chainId].VAULTS.address[4] },
// ];

export const stables = (chainId: string | number) => [
  { name: "USDC", decimals: 9, ...contracts[chainId].USDC },
  { name: "DAI", decimals: 9, ...contracts[chainId].DAI },
  { name: "USDT", decimals: 9, ...contracts[chainId].USDT },
  { name: "BUSD", decimals: 9, ...contracts[chainId].BUSD },
  { name: "FRAX", decimals: 9, ...contracts[chainId].FRAX },
  { name: "svLE", decimals: 9, ...contracts[chainId].STABLEV },
];

export const liquids = (chainId: string | number) => [
  { name: "WEVMOS", decimals: 18, ...contracts[chainId].WEVMOS },
  { name: "ATOM", decimals: 6, ...contracts[chainId].ATOM },
  { name: "WETH", decimals: 18, ...contracts[chainId].WETH },
  { name: "DIA", decimals: 18, ...contracts[chainId].DIA },
];
