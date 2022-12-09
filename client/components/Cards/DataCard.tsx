import Image from "next/image";
import React, { FC } from "react";
import { IBalance } from "../../lib/types";

const DataCard: FC<IBalance> = (props, { key }) => {
  return (
    <div
      className="card md:w-64 bg-primary text-primary-content relative"
      key={key}
    >
      <div className="badge absolute right-2 top-2 font-semibold">vault</div>
      <div className="card-body p-5 pt-8">
        <div className="card-title flex justify-between text-base">
          <div className="gap-4 inline-flex">
            <div className="avatar">
              {props?.total ? (
                <h2 className="card-title">Total :</h2>
              ) : (
                <div className="w-16 mask mask-hexagon">
                  <Image
                    src={`/${props?.symbol}.svg`}
                    alt={`${props?.symbol} logo`}
                    fill
                  />
                </div>
              )}
            </div>
            <div>
              {props?.total !== true && (
                <h2 className="card-title truncate">
                  $
                  {props?.value?.toLocaleString("en-US", {
                    maximumFractionDigits: 2,
                  })}
                </h2>
              )}
              <p className="text-slate-300 truncate">
                {props?.amount?.toLocaleString("en-US", {
                  maximumFractionDigits: 2,
                })}{" "}
                {!props?.total && props?.symbol}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DataCard;
