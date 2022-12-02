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
    <div className="flex space-x-4 overflow-x-auto justify-around">
      <DataCard key={3} name="BUSD" symbol="BUSD" amount={0} value={0} />
      <DataCard key={3} name="USDT" symbol="USDT" amount={0} value={0} />
      <DataCard key={3} name="DAI" symbol="DAI" amount={0} value={0} />
      <DataCard key={3} name="FRAX" symbol="FRAX" amount={0} value={0} />
      {isStableVaultBalancesAvailable && renderList()}
    </div>
  );
};

export default SStats;