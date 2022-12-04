import { start } from "repl";
import create from "zustand";
import {
  getBorrows,
  getLends,
  getLiquidBalances,
  getPositions,
  getStableBalances,
} from "../lib/data";
import { IBalance, IBorrow, ILend, IPosition } from "../lib/types";

export interface IDappStore {
  setAll: (chain: string) => void;

  // partial lenders nodes
  lenders: ILend[];
  isLendersAvailable: boolean;
  setLenders: (lenders: ILend[]) => void;
  getLenders: (sart: number, end: number) => ILend[];

  // partial borowers nodes
  borrowers: IBorrow[];
  isBorrowersAvailable: boolean;
  setBorrowers: (borrowers: IBorrow[]) => void;
  getBorrowers: (sart: number, end: number) => IBorrow[];

  // filled nodes
  positions: IPosition[];
  isPositionsAvailable: boolean;
  setPositions: (borrowers: IPosition[]) => void;
  getPositions: (start: number, end: number) => IPosition[];

  // stable Vault balances
  stableVaultBalances: IBalance[];
  isStableVaultBalancesAvailable: boolean;
  setStableVaultBalances: (balances: IBalance[]) => void;

  // liquid vault balances
  liquidVaultBalances: IBalance[];
  isLiquidVaultBalancesAvailable: boolean;
  setLiquidVaultBalances: (balances: IBalance[]) => void;
}

const useStore = create<IDappStore>((set, get) => ({
  setAll: async (chain = "9000") => {
    const [lenders, borrowers, positions, stables, liquids] = await Promise.all(
      [
        getLends(chain),
        getBorrows(chain),
        getPositions(chain),
        getStableBalances(chain),
        getLiquidBalances(chain),
      ]
    );
    get().setLenders(lenders);
    get().setBorrowers(borrowers);
    get().setPositions(positions);
    get().setStableVaultBalances(stables);
    get().setLiquidVaultBalances(liquids);
  },

  lenders: [],
  isLendersAvailable: false,
  setLenders: (lenders: ILend[]) =>
    set((state) => ({ lenders: lenders, isLendersAvailable: true })),
  getLenders: (start: number, end: number) =>
    get().isBorrowersAvailable ? get().lenders.slice(start, end) : [],

  borrowers: [],
  isBorrowersAvailable: false,
  setBorrowers: (borrowers: IBorrow[]) =>
    set((state) => ({ borrowers: borrowers, isBorrowersAvailable: true })),
  getBorrowers: (start: number, end: number) =>
    get().isBorrowersAvailable ? get().borrowers.slice(start, end) : [],

  positions: [],
  isPositionsAvailable: false,
  setPositions: (positions: IPosition[]) =>
    set((state) => ({ positions: positions, isPositionsAvailable: true })),
  getPositions: (start: number, end: number) =>
    get().isPositionsAvailable ? get().positions.slice(start, end) : [],

  stableVaultBalances: [],
  isStableVaultBalancesAvailable: false,
  setStableVaultBalances: (balances: IBalance[]) =>
    set((state) => ({
      stableVaultBalances: balances,
      isStableVaultBalancesAvailable: true,
    })),

  liquidVaultBalances: [],
  isLiquidVaultBalancesAvailable: false,
  setLiquidVaultBalances: (balances: IBalance[]) =>
    set({
      liquidVaultBalances: balances,
      isLiquidVaultBalancesAvailable: true,
    }),
}));

export default useStore;
