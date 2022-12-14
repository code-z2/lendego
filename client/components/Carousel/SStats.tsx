import React from "react";
import useStore from "../../store/useStore";
import DataCard from "../Cards/DataCard";

const SStats = () => {
  const { isStableVaultBalancesAvailable, stableVaultBalances } = useStore(
    (state) => state
  );
  const renderList = (): JSX.Element[] => {
    return stableVaultBalances.map((el, id) => {
      return (
        <DataCard
          key={id}
          name={el.name}
          symbol={el.symbol}
          amount={el.amount}
          value={el.amount}
          total={el.total}
        />
      );
    });
  };
  return (
    <div className="overflow-x-hidden">
      <div className="flex gap-4 overflow-x-auto lg:justify-evenly">
        {isStableVaultBalancesAvailable && renderList()}
      </div>
    </div>
  );
};

export default SStats;
