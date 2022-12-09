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
      <div className="flex gap-4 overflow-x-auto">
        <DataCard key={10} name="BUSD" symbol="BUSD" amount={0} value={0} />
        <DataCard key={11} name="USDT" symbol="USDT" amount={0} value={0} />
        <DataCard key={12} name="DAI" symbol="DAI" amount={0} value={0} />
        <DataCard key={13} name="FRAX" symbol="FRAX" amount={0} value={0} />
        {isStableVaultBalancesAvailable && renderList()}
      </div>
    </div>
  );
};

export default SStats;
