import { NextPage } from "next";
import { useState } from "react";
import LoanCard from "../components/Cards/LoanCard";
import SStats from "../components/Carousel/SStats";
import Linkto from "../components/Link/Link";
import Pagination from "../components/Pagination/Pagination";
import useStore from "../store/useStore";

const Home: NextPage = () => {
  const { lenders, isLendersAvailable, getLenders } = useStore(
    (state) => state
  );
  const [pagination, setPagination] = useState(0);

  const renderList = (): (JSX.Element | undefined)[] => {
    return getLenders(pagination, pagination + 19).map((el, id) => {
      if (el.acceptingRequests && !el.filled) {
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
          />
        );
      }
    });
  };
  return (
    <div>
      <SStats />
      <div className="divider my-6"></div>
      <Linkto />
      <div className="grid lg:grid-cols-4 md:grid-cols-2 grid-cols-1 gap-10 mt-8">
        {isLendersAvailable && renderList()}
      </div>
      <div className="flex">
        {isLendersAvailable && (
          <Pagination
            pagination={pagination}
            maxLength={lenders.length}
            callBack={setPagination}
          />
        )}
      </div>
    </div>
  );
};

export default Home;
