import { ContractInterface } from "ethers";

type contractObj = { address: string; abi: ContractInterface };
export interface IContracts {
  [key: string]: {
    USDC: contractObj;
    ATOM: contractObj;
    WETH: contractObj;
    DIA: contractObj;
    EGO: contractObj;
    ORACLE: contractObj;
    STABLEV: contractObj;
    LIQUIDV: contractObj;
  };
}

export interface ILend {
  lnodeId?: number;
  lender: string;
  stableId: number; // choiceOfStable
  stableAddress: string;
  stableName: string; // choiceOfStable name
  interestRate: number;
  assets: number | string;
  filled: boolean;
  acceptingRequests: boolean;
}

export interface IBorrow {
  bnodeId?: number;
  borrower: string;
  collateralAddress: string;
  collateralName: string;
  collateralAmount: number | string;
  collateralId: number;
  maximumExpectedOutput: number | string;
  tenure: number;
  maxPayableInterest: number;
  restricted: boolean;
}

export interface IPosition {
  nodeId: number;
  createdAt: Date | string;
  expiresAt: Date | string;
  isOpen: boolean;
  lend: ILend;
  borrow: IBorrow;
}

export interface IBalance {
  name: string;
  symbol: string;
  amount: number | string;
  logo?: string;
  value?: number | string;
  total?: boolean;
}

export interface ICovalentResponse {
  data: { data: { items: {}[] } };
}
