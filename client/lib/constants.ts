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
};

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
