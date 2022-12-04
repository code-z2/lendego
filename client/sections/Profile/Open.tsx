import React, { useState } from "react";
import LoanCard from "../../components/Cards/LoanCard";
import Pagination from "../../components/Pagination/Pagination";
import Empty from "../../components/SuspenseUI/Empty";
import Loading from "../../components/SuspenseUI/Loading";
import { IBorrow, ILend } from "../../lib/types";
import useStore from "../../store/useStore";

const OpenPositions = ({ address }: { address: string }) => {
  const [pagination, setPagination] = useState(0);
  const { lenders, borrowers, isLendersAvailable, isBorrowersAvailable } =
    useStore((state) => state);

  const total: (ILend | IBorrow)[] =
    isLendersAvailable || isBorrowersAvailable
      ? [...lenders, ...borrowers]
      : [];

  const getTotal = (start: number, end: number): (ILend | IBorrow)[] => {
    return isLendersAvailable || isBorrowersAvailable
      ? total.slice(start, end)
      : [];
  };

  const renderList = (): (JSX.Element | undefined)[] => {
    return getTotal(pagination, pagination + 19)
      .filter(
        (el: any) =>
          ((el.acceptingRequests && !el.filled) || el.borrower) &&
          (el.lender === address || el.borrower === address)
      )
      .map((el: any, id) => {
        return (
          <LoanCard
            lnodeId={el.lnodeId}
            lender={el.lender}
            stableId={el.stableId}
            stableAddress={el.stableAddress}
            stableName={el.stableName}
            interestRate={el.interestRate}
            assets={el.assets}
            filled={el.filled}
            acceptingRequests={el.acceptingRequests}
            key={id}
            bnodeId={el.bnodeId}
            collateralAddress={el.collateralAddress}
            collateralId={el.collateralId}
            collateralAmount={el.collateralAmount}
            maxPayableInterest={el.maxPayableInterest}
            maximumExpectedOutput={el.maximumExpectedOutput}
            collateralName={el.collateralName}
            borrower={el.borrower}
            tenure={el.tenure}
            restricted={el.restricted}
          />
        );
      });
  };
  return (
    <div className="space-y-4 py-10">
      <div className="font-bold text-base">
        <h2>Open</h2>
      </div>
      {isLendersAvailable || isBorrowersAvailable ? (
        <div>
          {total?.length > 0 ? (
            <div className="grid lg:grid-cols-4 md:grid-cols-2 grid-cols-1 gap-10 mt-8">
              {(isLendersAvailable || isBorrowersAvailable) && renderList()}
            </div>
          ) : (
            <Empty />
          )}
          <div className="flex">
            {total?.length > 0 && (
              <Pagination
                pagination={pagination}
                maxLength={total.length}
                callBack={setPagination}
              />
            )}
          </div>
        </div>
      ) : (
        <Loading />
      )}
    </div>
  );
};

export default OpenPositions;
