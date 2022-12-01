import React from "react";

const DataCard = () => {
  return (
    <div className="card w-64 bg-primary text-primary-content relative">
      <div className="badge absolute right-2 top-2 font-semibold">vault</div>
      <div className="card-body p-5">
        <div className="card-title flex justify-between text-base">
          <div className="gap-4 inline-flex">
            <div className="avatar">
              <div className="w-16 mask mask-hexagon">
                <img src="/USDC.svg" />
              </div>
            </div>
            <div>
              <h2 className="card-title">$4,000</h2>
              <p className="text-slate-300">4,000 USDC</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DataCard;
