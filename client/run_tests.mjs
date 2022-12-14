import ethers, { Wallet } from "ethers";
import abi from "./lib/ABI/ego.json" assert { type: "json" };
import lvabi from "./lib/ABI/liquidvault.json" assert { type: "json" };

export async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://eth.bd.evmos.dev:8545"
  );
  const ego = new ethers.Contract(
    "0x56B5b64675FCf880fb1385E97A81137d6bA1A3e0",
    abi,
    provider
  );

  const [allLends, allBorrows, allPositions, stableV, liquidV] =
    await Promise.all([
      ego.getAllLenders(),
      ego.getAllBorrowers(),
      ego.getAllPositions(),
      ego.getStableVaultAddress(),
      ego.getLiquidVaultAddress(),
    ]);

  const liquidFactory = new ethers.Contract(liquidV, lvabi, provider);
  console.log(
    "lenders: ",
    allLends,
    allLends.length,
    "borrowers: ",
    allBorrows,
    allBorrows.length,
    "positions: ",
    allPositions,
    allPositions.length,
    "stable vault",
    stableV,
    "liquid vault",
    liquidV
  );
  const database = await liquidFactory.asset();
  console.log("db is", database);
}

main();
