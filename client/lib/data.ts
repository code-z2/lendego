import axios, { AxiosResponse } from "axios";
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
const acceptedStables = ["USDC", "DAI", "USDT", "BUSD", "FRAX"];
const acceptedLiquids = ["ATOM", "DIA", "WETH", "WEVMOS"];

export const ego = (chainId: string) =>
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
  const collateralIndex = parseInt(formatUnits(data.indexOfCollateral, 0));
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
      stables(9000)[0].decimals
    ),
    tenure: parseInt(formatUnits(data.tenure, 0)),
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

function parseDate(timestamp: number, tenure: number) {
  const datetime = new Date(timestamp * 1000);
  datetime.setDate(datetime.getDate() + tenure);
  return datetime.toLocaleDateString();
}

function formatPositions(data: unknown[]): IPosition[] {
  const _formattedData: IPosition[] = new Array(data.length);
  data.map((el: any, id) => {
    _formattedData[id] = {
      nodeId: parseInt(formatEther(el.nodeId)),
      createdAt: parseDate(parseInt(formatUnits(el.timeStamp, 0)), 0),
      expiresAt: parseDate(
        parseInt(formatUnits(el.timeStamp, 0)),
        parseInt(formatUnits(el.borrow.tenure, 0))
      ),
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

async function getBalances(
  address: string,
  chainId: string
): Promise<{}[] | void> {
  const endpoint = `https://api.covalenthq.com/v1/${chainId}/address/${address}/balances_v2/?quote-currency=USD&no-nft-fetch=true&key=${process.env.NEXT_PUBLIC_COVALENTHQ_API_KEY}`;
  const res = await axios
    .get(endpoint)
    .then((response: ICovalentResponse) => response?.data?.data?.items)
    .catch((err) => console.log(err));
  return res;
}

function formatBalances(data: {}[] | void, accepted: Set<string>): IBalance[] {
  let total = 0;
  const _formattedData: IBalance[] = new Array();
  data?.map((el: any, id: number) => {
    accepted.has(el.contract_ticker_symbol)
      ? (_formattedData[id] = {
          name: el.contract_name,
          symbol: el.contract_ticker_symbol,
          amount: parseFloat(formatUnits(el.balance, el.contract_decimals)),
          logo: el.logo_url,
          address: el.contract_address,
        })
      : null;
    total += parseFloat(formatUnits(el.balance, el.contract_decimals));
  });
  _formattedData[_formattedData.length] = {
    name: "Vault",
    symbol: "vToken",
    amount: total,
    total: true,
  };
  return _formattedData;
}

async function getStableBalances(chain: string) {
  const balances = await getBalances(contracts[chain].STABLEV.address, chain);
  const formattedData: IBalance[] = formatBalances(
    balances,
    new Set(acceptedStables)
  );
  return formattedData;
}

async function getLiquidBalances(chain: string) {
  const balances = await getBalances(contracts[chain].LIQUIDV.address, chain);
  const formattedData: IBalance[] = formatBalances(
    balances,
    new Set(acceptedLiquids)
  );
  return formattedData;
}

async function getUserBalances(chain: string, address: string) {
  const balances = await getBalances(address, chain);
  const formattedData: IBalance[] = formatBalances(
    balances,
    new Set(acceptedStables.concat(acceptedLiquids))
  );
  return formattedData;
}

export {
  getLends,
  getBorrows,
  getPositions,
  getLiquidBalances,
  getStableBalances,
  getUserBalances,
};
