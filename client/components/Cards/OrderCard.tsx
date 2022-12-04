import React from "react";
import { useForm } from "react-hook-form";
import { useSession } from "next-auth/react";
import Seed from "../Blockies/Seed";
import { formatAddress } from "../../utils/formatAddress";

const OrderCard = ({ node }: { node: string }) => {
  const { data } = useSession();
  const {
    register,
    handleSubmit,
    watch,
    reset,
    formState: { errors },
  } = useForm();

  const onSubmit = handleSubmit((data) => console.log(data));
  return (
    <form onSubmit={onSubmit} className="w-full flex flex-col mt-1">
      <div className="card card-compact md:w-[28rem] bg-base-100 md:shadow-xl min-h-[14rem] bg-opacity-50 hover:shadow-md p-10 glass m-auto">
        <div className="card-body relative space-y-5">
          {/* from: borrower or lender */}

          {data?.user?.name ? (
            <div className="gap-2 inline-flex">
              <div className="avatar">
                <div className=" mask mask-hexagon">
                  {Seed(data?.user?.name, 3, 10)}
                </div>
              </div>
              <div className="font-light">
                {formatAddress(data?.user?.name)}
              </div>
            </div>
          ) : (
            <div className="badge badge-accent badge-outline">
              connect wallet first
            </div>
          )}
          {/* choice of stable lender */}
          {/* assets|usd lender|borrower */}
          {errors.amount && (
            <span className="mx-auto text-red-500 mb-2">
              please enter a valid amount
            </span>
          )}
          <div className="inline-flex gap-4 items-center">
            <div>
              <p className="text-slate-500 dark:text-red-100">Amount:</p>
            </div>
            <select className="select select-ghost" {...register("stableName")}>
              <option defaultValue="USDC">USDC</option>
              {node === "lend" && <option value="DAI">DAI</option>}
              {node === "lend" && <option value="USDT">USDT</option>}
              {node === "lend" && <option value="BUSD">BUSD</option>}
              {node === "lend" && <option value="FRAX">FRAX</option>}
            </select>
            <input
              type="text"
              placeholder="amount"
              className="input w-full p-2"
              {...register("amount", { required: true })}
            />
          </div>
          {/* tenure borrower */}
          {node === "borrow" && (
            <div className="inline-flex justify-between">
              <div>
                <p className="text-slate-500 dark:text-red-100">
                  tenure (Days):
                </p>
              </div>
              <div>
                <select
                  className="select select-ghost w-24"
                  {...register("tenure")}
                >
                  <option defaultValue="30">30</option>
                  <option value="60">60</option>
                  <option value="90">90</option>
                </select>
              </div>
            </div>
          )}
          {/* inerest rate for lender|borrower */}
          {errors.interest && (
            <span className="mx-auto text-red-500 mb-2">
              please add an interest rate
            </span>
          )}
          <div className="inline-flex justify-between">
            <div>
              <p className="text-slate-500 dark:text-red-100">interest rate:</p>
            </div>
            <div>
              <input
                type="text"
                placeholder="amount"
                className="input w-full p-2"
                {...register("interest", { required: true })}
              />
            </div>
          </div>
          {/* collateral borrower */}
          {errors.collateral && (
            <span className="mx-auto text-red-500 mb-2">
              enter at least 125% of collateral
            </span>
          )}
          {node === "borrow" && (
            <div className="inline-flex gap-4 items-center">
              <div>
                <p className="text-slate-500 dark:text-red-100">collateral:</p>
              </div>
              <select
                className="select select-ghost"
                {...register("collateralName")}
              >
                <option defaultValue="EVMOS">Evmos</option>
                <option value="ATOM">Atom</option>
                <option value="WETH">Weth</option>
                <option value="WETH">DIA</option>
              </select>
              <input
                type="text"
                placeholder="amount"
                className="input w-full p-2"
                {...register("collateral", { required: true })}
              />
            </div>
          )}
          {/* submit button */}

          {data?.user?.name && (
            <button
              className={`btn btn-link lowercase text-teal-600 disabled:text-slate-700 mx-auto ${
                !data?.user?.name && "btn-disabled"
              }`}
              type="submit"
              disabled={!data?.user?.name}
            >
              submit
            </button>
          )}
        </div>
      </div>
    </form>
  );
};

export default OrderCard;
