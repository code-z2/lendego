import { start } from "repl";
import create from "zustand";
import {
  getBorrows,
  getLends,
  getLiquidBalances,
  getPositions,
  getStableBalances,
} from "../lib/data";

export interface IDappStore {
  setAll: (chain: string) => void;

  // partial lenders nodes
  lenders: {}[];
  isLendersAvailable: boolean;
  setLenders: (lenders: {}[]) => void;
  getLenders: (sart: number, end: number) => void;

  // partial borowers nodes
  borrowers: {}[];
  isBorrowersAvailable: boolean;
  setBorrowers: (borrowers: {}[]) => void;
  getBorrowers: (sart: number, end: number) => void;

  // filled nodes
  positions: {}[];
  isPositionsAvailable: boolean;
  setPositions: (borrowers: {}[]) => void;
  getPositions: (start: number, end: number) => void;

  // stable Vault balances
  stableVaultBalances: {}[];
  isStableVaultBalancesAvailable: boolean;
  setStableVaultBalances: (balances: {}[]) => void;

  // liquid vault balances
  liquidVaultBalances: {}[];
  isLiquidVaultBalancesAvailable: boolean;
  setLiquidVaultBalances: (balances: {}[]) => void;
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
  setLenders: (lenders: {}[]) =>
    set((state) => ({ lenders: lenders, isLendersAvailable: true })),
  getLenders: (start: number, end: number) =>
    get().isBorrowersAvailable ? get().lenders.slice(start, end) : [],

  borrowers: [],
  isBorrowersAvailable: false,
  setBorrowers: (borrowers: {}[]) =>
    set((state) => ({ borrowers: borrowers, isBorrowersAvailable: true })),
  getBorrowers: (start: number, end: number) =>
    get().isBorrowersAvailable ? get().borrowers.slice(start, end) : [],

  positions: [],
  isPositionsAvailable: false,
  setPositions: (positions: {}[]) =>
    set((state) => ({ positions: positions, isPositionsAvailable: true })),
  getPositions: (start: number, end: number) =>
    get().isPositionsAvailable ? get().positions.slice(start, end) : [],

  stableVaultBalances: [],
  isStableVaultBalancesAvailable: false,
  setStableVaultBalances: (balances: {}[]) =>
    set((state) => ({
      stableVaultBalances: balances,
      isStableVaultBalancesAvailable: true,
    })),

  liquidVaultBalances: [],
  isLiquidVaultBalancesAvailable: false,
  setLiquidVaultBalances: (balances: {}[]) =>
    set({
      liquidVaultBalances: balances,
      isLiquidVaultBalancesAvailable: true,
    }),
}));

export default useStore;
