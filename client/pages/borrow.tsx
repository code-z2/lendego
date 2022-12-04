import { NextPage } from "next";
import { useState } from "react";
import LoanCard from "../components/Cards/LoanCard";
import LStats from "../components/Carousel/LStats";
import Linkto from "../components/Link/Link";
import Pagination from "../components/Pagination/Pagination";
import Empty from "../components/SuspenseUI/Empty";
import Loading from "../components/SuspenseUI/Loading";
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
      {isBorrowersAvailable ? (
        <div>
          {borrowers?.length > 0 ? (
            <div className="grid lg:grid-cols-4 md:grid-cols-2 grid-cols-1 gap-10 mt-8">
              {isBorrowersAvailable && renderList()}
            </div>
          ) : (
            <Empty />
          )}
          <div className="flex">
            {borrowers?.length > 0 && (
              <Pagination
                pagination={pagination}
                maxLength={borrowers.length}
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

export default Borrow;
