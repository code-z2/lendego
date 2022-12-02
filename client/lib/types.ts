import { ContractInterface } from "ethers";
import React, { SetStateAction } from "react";

type contractObj = { address: string; abi: ContractInterface };
export interface IContracts {
  [key: string]: {
    WEVMOS: contractObj;
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
  address?: string;
}

export interface ICovalentResponse {
  data: { data: { items: {}[] } };
}

export type LoanCardPropsType = IBorrow | ILend;

export interface IBorrowForm {
  collateral: number | string;
  amount: number | string;
}

export interface IPagination {
  pagination: number;
  maxLength: number;
  callBack: React.Dispatch<SetStateAction<number>>;
}
