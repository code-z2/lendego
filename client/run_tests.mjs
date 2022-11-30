import ethers from "ethers";
import abi from "./lib/ABI/ego.json" assert { type: "json" };

export async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://eth.bd.evmos.dev:8545"
  );
  const ego = new ethers.Contract(
    "0x7051AA73D7b731BCA2D62aB466b000c5e08eb4Fe",
    abi,
    provider
  );
  const [allLends, allBorrows, allPositions] = await Promise.all([
    ego.getAllLenders(),
    ego.getAllBorrowers(),
    ego.getAllPositions(),
  ]);
  console.log(
    "lenders: ",
    allLends,
    allLends.length,
    "borrowers: ",
    allBorrows,
    allBorrows.length,
    "positions: ",
    allPositions,
    allPositions.length
  );
}

main();
