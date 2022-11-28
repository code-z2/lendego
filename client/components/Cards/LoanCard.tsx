import Image from "next/image";
import React from "react";

const LoanCard = () => {
  return (
    <div className="card card-compact md:w-72 bg-base-100 md:shadow-xl h-56 bg-opacity-50 hover:shadow-md">
      <div className="card-body relative">
        <h2 className="card-title text-base">
          Next Video Build: Build a fullstack Dapp on polygon
        </h2>
        <p className="text-red-800 dark:text-red-100">
          Tue, Nov 22, 2022 6:30 PM WAT
        </p>
        <p className=" font-normal text-slate-600 text-sm dark:text-slate-500">
          {
            [
              "Le Meriadian Gues house Lison",
              "Freeway Drive Bogota, Columbia",
              "online",
            ][Math.floor(Math.random() * 3)]
          }
        </p>
        <p className="font-bold text-slate-500 dark:text-slate-400">
          {["0.23 ETH", "Free"][Math.floor(Math.random() * 2)]}
        </p>
        <div className="card-actions justify-end">
          <p className="font-medium text-slate-500 dark:text-slate-400">
            Hosted by: Encode.club
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoanCard;
