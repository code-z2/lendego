import React from "react";
import useStore from "../../store/useStore";
import DataCard from "../Cards/DataCard";

const LStats = () => {
  const { isLiquidVaultBalancesAvailable, liquidVaultBalances } = useStore(
    (state) => state
  );
  const renderList = (): JSX.Element[] => {
    return liquidVaultBalances.map((el, id) => {
      return (
        <DataCard
          key={id}
          name={el.name}
          symbol={el.symbol}
          amount={el.amount}
          value={(el.amount as number) * 12}
          total={el.total}
        />
      );
    });
  };
  return (
    <div className="flex space-x-4 overflow-x-auto justify-around">
      {isLiquidVaultBalancesAvailable && renderList()}
    </div>
  );
};

export default LStats;
