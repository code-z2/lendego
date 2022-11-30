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
    USDC: {
      address: "0x70F6C56a5D53DAff1d3418B74a2D40692eDafbeF",
      abi: usdcAbi,
    },
    ATOM: {
      address: "0xeB1d5b667C3aAe26A7E024492eF0a481f3D12aF1",
      abi: atomAbi,
    },
    WETH: {
      address: "0x28377a94B111d331a7965BB8707c43eD34f70586",
      abi: wethAbi,
    },
    DIA: { address: "0xC16bEC81A358498F80f8D156d94b4005a6544174", abi: diaAbi },
    ORACLE: {
      address: "0xB40f542B10Acdf955E5AC4f4523E6ac8f602F402",
      abi: oracleAbi,
    },
    STABLEV: {
      address: "0x6A6744B3915aF704D7a8500C099D0283C84a5842",
      abi: vstableAbi,
    },
    LIQUIDV: {
      address: "0xa700EF62058A27705996D727E2B88b323209D2Ac",
      abi: vliquidAbi,
    },
    EGO: { address: "0x7051AA73D7b731BCA2D62aB466b000c5e08eb4Fe", abi: egoAbi },
  },
};

export const stables = (chainId: string | number) => [
  { name: "USDC", decimals: 9, ...contracts[chainId].USDC },
  { name: "DAI", decimals: 9, ...contracts[chainId].USDC },
  { name: "USDT", decimals: 9, ...contracts[chainId].USDC },
  { name: "BUSD", decimals: 9, ...contracts[chainId].USDC },
  { name: "FRAX", decimals: 9, ...contracts[chainId].USDC },
];

export const liquids = (chainId: string | number) => [
  { name: "ATOM", decimals: 6, ...contracts[chainId].ATOM },
  { name: "WETH", decimals: 18, ...contracts[chainId].WETH },
  { name: "DIA", decimals: 18, ...contracts[chainId].DIA },
];
