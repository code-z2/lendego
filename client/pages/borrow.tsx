import { NextPage } from "next";
import { useState } from "react";
import LoanCard from "../components/Cards/LoanCard";
import LStats from "../components/Carousel/LStats";
import Linkto from "../components/Link/Link";
import Pagination from "../components/Pagination/Pagination";
import useStore from "../store/useStore";

const Borrow: NextPage = () => {
  const { borrowers, isBorrowersAvailable, getBorrowers } = useStore(
    (state) => state
  );
  const [pagination, setPagination] = useState(0);

  const renderList = (): JSX.Element[] => {
    return getBorrowers(pagination, pagination + 19).map((el, id) => {
      return (
        <LoanCard
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
          key={id}
        />
      );
    });
  };
  return (
    <div>
      <LStats />
      <div className="divider my-6"></div>
      <Linkto />
      <div className="grid lg:grid-cols-4 md:grid-cols-2 grid-cols-1 gap-10 mt-8">
        {isBorrowersAvailable && renderList()}
      </div>
      <div className="flex">
        {isBorrowersAvailable && (
          <Pagination
            pagination={pagination}
            maxLength={borrowers.length}
            callBack={setPagination}
          />
        )}
      </div>
    </div>
  );
};

export default Borrow;
