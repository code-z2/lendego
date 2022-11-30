import axios from "axios";
import { ethers } from "ethers";
import { formatEther, formatUnits } from "ethers/lib/utils.js";
import { contracts, liquids, stables } from "./constants";
import {
  IBorrow,
  ILend,
  IPosition,
  ICovalentResponse,
  IBalance,
} from "./types";

const EMVOS_RPC_URL: string = process.env.NEXT_PUBLIC_EMVOS_RPC_URL as string;
const provider = new ethers.providers.JsonRpcProvider(EMVOS_RPC_URL);
const ego = (chainId: string) =>
  new ethers.Contract(
    contracts[chainId].EGO.address,
    contracts[chainId].EGO.abi,
    provider
  );

function formatLendNode(data: any, id?: number): ILend {
  return {
    lnodeId: id,
    lender: data.lender,
    stableId: data.choiceOfStable, // choiceOfStable
    stableAddress: stables(9000)[data.choiceOfStable].address,
    stableName: stables(9000)[data.choiceOfStable].name, // choiceOfStable name
    interestRate: data.interestRate,
    assets: formatUnits(
      data.assets,
      stables(9000)[data.choiceOfStable].decimals
    ),
    filled: data.filled,
    acceptingRequests: data.acceptingRequests,
  };
}
function formatLends(data: unknown[]): ILend[] {
  const _formattedData: ILend[] = new Array(data.length);
  data.map((el, id) => {
    _formattedData[id] = formatLendNode(el, id);
  });
  return _formattedData;
}
async function getLends(chain: string) {
  const allLends = await ego(chain).getAllLenders();
  const formattedData = formatLends(allLends);
  return formattedData;
}

function formatBorrowNode(data: any, id?: number): IBorrow {
  const collateralIndex = parseInt(formatEther(data.indexOfCollateral));
  return {
    bnodeId: id,
    borrower: data.borrower,
    collateralAddress: data.collateral,
    collateralName: liquids(9000)[collateralIndex].name,
    collateralAmount: formatUnits(
      data.collateralIn,
      liquids(9000)[collateralIndex].decimals
    ),
    collateralId: collateralIndex,
    maximumExpectedOutput: formatUnits(
      data.maximumExpectedOutput,
      liquids(9000)[collateralIndex].decimals
    ),
    tenure: parseInt(formatEther(data.tenure)),
    maxPayableInterest: data.maxPayableInterest,
    restricted: data.restricted,
  };
}
function formatBorrows(data: unknown[]): IBorrow[] {
  const _formattedData: IBorrow[] = new Array(data.length);
  data.map((el, id) => {
    _formattedData[id] = formatBorrowNode(el, id);
  });
  return _formattedData;
}
async function getBorrows(chain: string) {
  const allBorrows = await ego(chain).getAllBorrowers();
  const formattedData = formatBorrows(allBorrows);
  return formattedData;
}

function formatPositions(data: unknown[]): IPosition[] {
  const _formattedData: IPosition[] = new Array(data.length);
  data.map((el: any, id) => {
    _formattedData[id] = {
      nodeId: parseInt(formatEther(el.nodeId)),
      createdAt: formatEther(el.timeStamp),
      expiresAt: formatEther(el.timeStamp),
      isOpen: el.isOpen,
      borrow: formatBorrowNode(el.borrow),
      lend: formatLendNode(el.lend),
    };
  });
  return _formattedData;
}
async function getPositions(chain: string) {
  const allPostions = await ego(chain).getAllPositions();
  const formattedData = formatPositions(allPostions);
  return formattedData;
}

async function getBalances(address: string, chainId: string) {
  const endpoint = `https://api.covalenthq.com/v1/${chainId}/address/${address}/balances_v2/?quote-currency=USD&no-nft-fetch=true&key=${process.env.NEXT_PUBLIC_COVALENTHQ_API_KEY}`;
  const res = await axios
    .get(endpoint)
    .then((response: ICovalentResponse) => response?.data?.data?.items)
    .catch((err) => console.log(err));
  return res;
}

async function getStableBalances(chain: string) {
  let total = 0;
  const accepted = ["USDC", "DAI", "USDT", "BUSD", "FRAX"];
  const balances = await getBalances(contracts[chain].STABLEV.address, chain);
  const formattedData: IBalance[] = new Array();
  balances?.map((el: any, id) => {
    accepted.includes(el.contract_name)
      ? (formattedData[id] = {
          name: el.contract_name,
          symbol: el.contract_ticker_symbol,
          amount: formatUnits(el.balance, el.contract_decimals),
          logo: el.logo_url,
        })
      : null;
    total += el.balance;
  });
  formattedData[formattedData.length] = {
    name: "stableV",
    symbol: "svToken",
    amount: total,
    total: true,
  };
  return formattedData;
}

async function getLiquidBalances(chain: string) {
  let total = 0;
  const accepted = ["ATOM", "DIA", "WETH"];
  const balances = await getBalances(contracts[chain].LIQUIDV.address, chain);
  const formattedData: IBalance[] = new Array();
  balances?.map((el: any, id) => {
    accepted.includes(el.contract_name)
      ? (formattedData[id] = {
          name: el.contract_name,
          symbol: el.contract_ticker_symbol,
          amount: formatUnits(el.balance, el.contract_decimals),
          logo: el.logo_url,
        })
      : null;
    total += el.balance;
  });
  formattedData[formattedData.length] = {
    name: "liquidV",
    symbol: "lvToken",
    amount: total,
    total: true,
  };
  return formattedData;
}

export {
  getLends,
  getBorrows,
  getPositions,
  getLiquidBalances,
  getStableBalances,
};
