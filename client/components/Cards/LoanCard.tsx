import Image from "next/image";
import React from "react";
import { formatAddress } from "../../utils/formatAddress";
import Seed from "../Blockies/Seed";
import { useForm } from "react-hook-form";
import { IBorrowForm } from "../../lib/types";

const LoanCard = () => {
  const {
    register,
    handleSubmit,
    watch,
    reset,
    formState: { errors },
  } = useForm<IBorrowForm>();
  const onSubmit = handleSubmit((data) => console.log(data));

  return (
    <div className="card card-compact md:w-72 bg-base-100 md:shadow-xl min-h-[14rem] bg-opacity-50 hover:shadow-md">
      <div className="card-body relative">
        <div className="card-title flex justify-between text-base">
          <div className="gap-2 inline-flex">
            <div className="avatar">
              <div className=" mask mask-hexagon">
                {Seed("0x74b913B671b7d77E50062151cd82A7A5fEF9e92a")}
              </div>
            </div>
            <div className="font-light">
              {formatAddress("0x74b913B671b7d77E50062151cd82A7A5fEF9e92a")}
            </div>
          </div>
          <div>
            <div className="badge badge-accent badge-outline">open</div>
          </div>
        </div>
        <div>
          <p className="text-slate-500 dark:text-red-100">requesting:</p>
        </div>
        <div className="flex justify-between items-center font-bold p-2 text-slate-500 dark:text-slate-400">
          <div className=" inline-flex gap-2">
            <div className="avatar">
              <div className="w-8 rounded-xl">
                <img src="/USDC.svg" />
              </div>
            </div>
            <div className="my-auto">
              <p>USDC</p>
            </div>
          </div>
          <div>
            <p>3000</p>
          </div>
        </div>
        <div className="inline-flex justify-between">
          <div>
            <p className="text-slate-500 dark:text-red-100">interest rate:</p>
          </div>
          <div>
            <p className="text-slate-500 dark:text-red-100 inline-flex gap-1">
              {"15"}%{" "}
              <span>
                <svg
                  className="w-4 h-4 text-red-800"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fillRule="evenodd"
                    d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                    clipRule="evenodd"
                  ></path>
                </svg>
              </span>
            </p>
          </div>
        </div>
        <div className="inline-flex justify-between">
          <div>
            <p className="text-slate-500 dark:text-red-100">tenure:</p>
          </div>
          <div>
            <p className="text-slate-500 dark:text-red-100">{30} Days</p>
          </div>
        </div>
        <div className="inline-flex justify-between">
          <div>
            <p className="text-slate-500 dark:text-red-100">collateral:</p>
          </div>
          <div>
            <p className="text-slate-500 dark:text-red-100 inline-flex">
              {"700"} Atom
              <span className="w-4 rounded-xl ml-1">
                <img src="/ATOM.svg" />
              </span>
            </p>
          </div>
        </div>
        <div className="inline-flex justify-between">
          <div>
            <p className="text-slate-500 dark:text-red-100">
              collateral ratio:
            </p>
          </div>
          <div>
            <p className="text-slate-500 dark:text-red-100 inline-flex gap-1">
              {"342"}%{" "}
              <span>
                <svg
                  className="w-4 h-4 text-green-500"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fillRule="evenodd"
                    d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z"
                    clipRule="evenodd"
                  ></path>
                </svg>
              </span>
            </p>
          </div>
        </div>
        <form onSubmit={onSubmit} className="w-full flex flex-col mt-1">
          {errors.amount && (
            <span className="mx-auto text-red-500 mb-2">
              This field is required
            </span>
          )}
          <div className="inline-flex gap-2">
            <select
              className="select select-ghost max-w-xs"
              {...register("collateral")}
            >
              <option defaultValue="Atom">Atom</option>
              <option value="WETH">WETH</option>
              <option value="WETH">DIA</option>
            </select>
            <input
              type="text"
              placeholder="amount"
              className="input w-full max-w-xs"
              {...register("amount", { required: true })}
            />
          </div>
          <button
            className="btn btn-link lowercase text-teal-600 mx-auto"
            type="submit"
          >
            fill order
          </button>
        </form>
      </div>
    </div>
  );
};

export default LoanCard;
