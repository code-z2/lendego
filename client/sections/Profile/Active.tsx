import React, { useState } from "react";
import PositionCard from "../../components/Cards/PositionCard";
import Pagination from "../../components/Pagination/Pagination";
import Empty from "../../components/SuspenseUI/Empty";
import Loading from "../../components/SuspenseUI/Loading";
import useStore from "../../store/useStore";

const ActivePositions = ({ address }: { address: string }) => {
  const [pagination, setPagination] = useState(0);
  const { positions, isPositionsAvailable, getPositions } = useStore(
    (state) => state
  );

  const filteredPosition = (start?: number, end?: number) =>
    isPositionsAvailable
      ? positions
          ?.filter(
            (el) =>
              el.isOpen &&
              (el.borrow.borrower === address || el.lend.lender === address)
          )
          .slice(start, end)
      : positions;
  const renderList = (): JSX.Element[] => {
    return filteredPosition(pagination, pagination + 19).map((el, id) => {
      return (
        <PositionCard
          nodeId={el.nodeId}
          createdAt={el.createdAt}
          expiresAt={el.expiresAt}
          isOpen={el.isOpen}
          borrow={el.borrow}
          lend={el.lend}
          key={id}
        />
      );
    });
  };
  return (
    <div className="space-y-4 py-10">
      <div className="font-bold text-base">
        <h2>Active</h2>
      </div>
      {isPositionsAvailable ? (
        <div>
          {filteredPosition()?.length > 0 ? (
            <div className="grid lg:grid-cols-4 md:grid-cols-2 grid-cols-1 gap-10 mt-8">
              {isPositionsAvailable && renderList()}
            </div>
          ) : (
            <Empty />
          )}
          <div className="flex">
            {filteredPosition().length > 0 && (
              <Pagination
                pagination={pagination}
                maxLength={filteredPosition().length}
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

export default ActivePositions;
