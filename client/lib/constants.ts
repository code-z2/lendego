import atomAbi from "./ABI/atom.json";
import usdcAbi from "./ABI/usdc.json";
import diaAbi from "./ABI/dia.json";
import wethAbi from "./ABI/weth.json";
import oracleAbi from "./ABI/oracle.json";
import egoAbi from "./ABI/ego.json";
import vstableAbi from "./ABI/stablevault.json";
import vliquidAbi from "./ABI/liquidvault.json";

export const contracts = {
  USDC: {
    address: "0x70F6C56a5D53DAff1d3418B74a2D40692eDafbeF",
    abi: usdcAbi,
  },
  ATOM: { address: "0xeB1d5b667C3aAe26A7E024492eF0a481f3D12aF1", abi: atomAbi },
  WETH: { address: "0x28377a94B111d331a7965BB8707c43eD34f70586", abi: wethAbi },
  DIA: { address: "0xC16bEC81A358498F80f8D156d94b4005a6544174", abi: diaAbi },
  ORACLE: { address: "", abi: oracleAbi },
  STABLEV: { address: "", abi: vstableAbi },
  LIQUIDV: { address: "", abi: vliquidAbi },
  EGO: { address: "", abi: egoAbi },
};

[
  0x70f6c56a5d53daff1d3418b74a2d40692edafbef,
  0x70f6c56a5d53daff1d3418b74a2d40692edafbef,
  0x70f6c56a5d53daff1d3418b74a2d40692edafbef,
  0x70f6c56a5d53daff1d3418b74a2d40692edafbef,
  0x70f6c56a5d53daff1d3418b74a2d40692edafbef,
];
