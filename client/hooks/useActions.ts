import { BigNumber, ethers, Signer } from "ethers";
import { formatUnits, parseUnits } from "ethers/lib/utils.js";
import { useContract, useSigner } from "wagmi";
import { contracts, liquids, stables } from "../lib/constants";
import { IBorrow, IBorrowForm, ILend, IPosition } from "../lib/types";

const useActions = ({ chainId }: { chainId: number }) => {
  const { data: signer } = useSigner({
    chainId: chainId,
    onError(error) {
      console.log("Error", error);
    },
    onSuccess(data) {
      console.log("Success", data);
    },
  });

  const contract = useContract({
    address: contracts[chainId].EGO.address,
    abi: contracts[chainId].EGO.abi as any,
    signerOrProvider: signer,
  });

  const _contractL = (liquidId: number) =>
    new ethers.Contract(
      liquids(chainId)[liquidId].address,
      liquids(chainId)[liquidId].abi as any,
      signer as Signer
    );

  const _contractS = (stableId: number) =>
    new ethers.Contract(
      stables(chainId)[stableId].address,
      stables(chainId)[stableId].abi as any,
      signer as Signer
    );

  const approveLiquid = async (amount: BigNumber, liquidId: number) => {
    const tx = await _contractL(liquidId)?.approve(
      contracts[chainId].LIQUIDV.address,
      amount
    );
    await tx.wait();
    console.log(tx.status);
  };

  const approveStable = async (amount: BigNumber, stableId: number) => {
    const tx = await _contractS(stableId)?.approve(
      contracts[chainId].STABLEV.address,
      amount
    );
    await tx.wait();
  };

  // working
  const createStablePosition = async (data: ILend) => {
    try {
      await approveStable(
        parseUnits(
          data.assets.toString(),
          stables(chainId)[data.stableId].decimals
        ),
        data.stableId
      );
      const tx = await contract?.createPosition(
        parseUnits(
          data.assets.toString(),
          stables(chainId)[data.stableId].decimals
        ),
        data.stableId,
        data.interestRate
      );
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const createUnstablePosition = async (data: IBorrow) => {
    const collateralId = parseUnits(data.collateralId.toString(), 0);
    try {
      await approveLiquid(
        parseUnits(
          data.collateralAmount.toString(),
          liquids(chainId)[data.collateralId].decimals
        ),
        data.collateralId
      );
      const tx = await contract?.createUnstablePosition(
        collateralId,
        parseUnits(
          data.collateralAmount.toString(),
          liquids(chainId)[data.collateralId].decimals
        ),
        parseUnits(
          data.maximumExpectedOutput.toString(),
          stables(chainId)[0].decimals
        ),
        parseUnits(data.tenure.toString(), 0),
        data.maxPayableInterest
      );
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const fillStablePosition = async (data: IBorrowForm) => {
    const collateral = parseInt(data.collateralId.toString());
    try {
      await approveLiquid(
        parseUnits(
          data.collateralAmount.toString(),
          liquids(chainId)[collateral].decimals
        ),
        collateral
      );
      const tx = await contract?.fillPosition(
        parseUnits(data.collateralId.toString(), 0),
        parseUnits(
          data.collateralAmount.toString(),
          liquids(chainId)[collateral].decimals
        ),
        data.nodeId,
        data.tenure
      );
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const fillUnstablePosition = async (
    nodeId: number,
    maximumExpectedOutput: string
  ) => {
    try {
      await approveStable(
        parseUnits(maximumExpectedOutput, stables(chainId)[0].decimals),
        0
      );
      const tx = await contract?.fillUnstablePosition(nodeId);
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const burnStablePosition = async (nodeId: number) => {
    console.log(nodeId);
    try {
      const tx = await contract?.burnPosition(nodeId);
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const burnUnstablePosition = async (nodeId: number) => {
    console.log(nodeId);
    try {
      const tx = await contract?.burnUnstablePosition(nodeId);
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const restrictLendersNode = async (nodeId: number) => {
    try {
      const tx = await contract?.deactivateLenderNode(nodeId);
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  const forcefullyExitLenderFromNode = async (nodeId: number) => {
    try {
      const tx = await contract?.exitLenderFromPosition(nodeId);
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const extendBorrowersLoan = async (nodeId: number) => {
    console.log(nodeId);
    try {
      const tx = await contract?.extendLoanDuration(nodeId);
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  // working
  const settleLoan = async (node: IPosition) => {
    try {
      const approve = await _contractS(node.lend.stableId)?.approve(
        contracts[chainId].EGO.address,
        parseUnits(
          ((node.lend.assets as number) * 1.3).toString(),
          stables(chainId)[node.lend.stableId].decimals
        )
      );
      await approve.wait();
      const tx = await contract?.exitBorrowerFromPosition(
        node.nodeId,
        node.borrow.borrower
      );
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    }
  };

  return {
    createStablePosition,
    createUnstablePosition,
    fillStablePosition,
    fillUnstablePosition,
    burnStablePosition,
    burnUnstablePosition,
    restrictLendersNode,
    forcefullyExitLenderFromNode,
    extendBorrowersLoan,
    settleLoan,
  };
};

export default useActions;
