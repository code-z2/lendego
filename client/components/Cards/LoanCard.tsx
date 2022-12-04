import Image from "next/image";
import React, { FC } from "react";
import { formatAddress } from "../../utils/formatAddress";
import Seed from "../Blockies/Seed";
import { useForm, Controller } from "react-hook-form";
import {
  IBorrow,
  IBorrowForm,
  ILend,
  LoanCardPropsType,
} from "../../lib/types";
import { useSession } from "next-auth/react";
import useActions from "../../hooks/useActions";

const LoanCard: FC<LoanCardPropsType> = (props, { key }) => {
  const {
    burnStablePosition,
    burnUnstablePosition,
    restrictLendersNode,
    fillStablePosition,
    fillUnstablePosition,
  } = useActions({
    chainId: 9000,
  });
  const lender = props as ILend;
  const borrower = props as IBorrow;
  const { data } = useSession();
  const {
    register,
    handleSubmit,
    watch,
    reset,
    control,
    formState: { errors },
  } = useForm<IBorrowForm>();

  const onSubmit = handleSubmit(async (data_) => {
    const data__ = { ...data_, nodeId: lender?.lnodeId! };
    console.log(data__);
    lender?.lender
      ? await fillStablePosition(data__)
      : await fillUnstablePosition(
          borrower?.bnodeId!,
          borrower?.maximumExpectedOutput.toString()!
        );
    reset();
  });

  const getQuote = (asset: number, collateral: number): JSX.Element => {
    const percentage = (100 / asset) * (collateral * 12);
    return <>{percentage}</>;
  };

  return (
    <div
      className="card card-compact md:w-72 bg-base-100 md:shadow-xl min-h-[14rem] bg-opacity-50 hover:shadow-md"
      key={key}
    >
      <div className="card-body relative">
        <div className="card-title flex justify-between text-base">
          <div className="gap-2 inline-flex">
            <div className="avatar">
              <div className=" mask mask-hexagon">
                {Seed(lender?.lender || borrower?.borrower, 3, 10)}
              </div>
            </div>
            <div className="font-light">
              {formatAddress(lender?.lender || borrower?.borrower)}
            </div>
          </div>
          <div>
            <div className="badge badge-accent badge-outline">
              {lender?.filled ? "active" : "open"}
            </div>
          </div>
        </div>
        <div>
          <p className="text-slate-500 dark:text-red-100">
            {borrower?.borrower ? "requesting:" : "offering"}
          </p>
        </div>
        <div className="flex justify-between items-center font-bold p-2 text-slate-500 dark:text-slate-400">
          <div className=" inline-flex gap-2">
            <div className="avatar">
              <div className="w-8 rounded-xl relative">
                <Image
                  src={`/${lender?.stableName || "USDC"}.svg`}
                  alt="loan card"
                  fill
                />
              </div>
            </div>
            <div className="my-auto">
              <p>{lender?.stableName || "USDC"}</p>
            </div>
          </div>
          <div>
            <p>
              {parseFloat(
                (lender?.assets || borrower?.maximumExpectedOutput)?.toString()
              ).toLocaleString("en-US", {
                maximumFractionDigits: 6,
              })}
            </p>
          </div>
        </div>
        <div className="inline-flex justify-between">
          <div>
            <p className="text-slate-500 dark:text-red-100">interest rate:</p>
          </div>
          <div>
            <p className="text-slate-500 dark:text-red-100 inline-flex gap-1">
              {lender?.interestRate || borrower?.maxPayableInterest}%{" "}
              <span>
                <svg
                  className="w-4 h-4 text-green-700"
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
        {borrower?.borrower && (
          <div className="inline-flex justify-between">
            <div>
              <p className="text-slate-500 dark:text-red-100">tenure:</p>
            </div>
            <div>
              <p className="text-slate-500 dark:text-red-100">
                {borrower?.tenure} Days
              </p>
            </div>
          </div>
        )}
        {borrower?.borrower && (
          <div className="inline-flex justify-between">
            <div>
              <p className="text-slate-500 dark:text-red-100">collateral:</p>
            </div>
            <div>
              <p className="text-slate-500 dark:text-red-100 inline-flex">
                {parseFloat(
                  borrower?.collateralAmount?.toString()
                ).toLocaleString("en-US", {
                  maximumFractionDigits: 5,
                })}{" "}
                {borrower?.collateralName}
                <span className="w-4 rounded-xl ml-1 relative">
                  <Image
                    src={`/${borrower?.collateralName}.svg`}
                    alt="loan card"
                    fill
                  />
                </span>
              </p>
            </div>
          </div>
        )}
        {borrower?.borrower && (
          <div className="inline-flex justify-between">
            <div>
              <p className="text-slate-500 dark:text-red-100">
                collateral ratio:
              </p>
            </div>
            <div>
              <p className="text-slate-500 dark:text-red-100 inline-flex gap-1">
                {getQuote(
                  parseFloat(borrower?.maximumExpectedOutput?.toString()),
                  parseFloat(borrower?.collateralAmount?.toString())
                )}
                %{" "}
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
        )}
        {data?.user?.name &&
        (lender?.lender === data?.user?.name ||
          borrower?.borrower === data?.user?.name) ? (
          <div>
            <button
              className={`btn btn-link lowercase text-orange-500 disabled:text-slate-700 mx-auto ${
                !data?.user?.name && "btn-disabled"
              }`}
              onClick={async () => {
                lender?.lender === data?.user?.name
                  ? await burnStablePosition(lender?.lnodeId as number)
                  : await burnUnstablePosition(borrower?.bnodeId as number);
              }}
              disabled={!data?.user?.name}
            >
              burn
            </button>
            {lender?.lender === data?.user?.name && (
              <button
                className={`btn btn-link lowercase text-orange-500 disabled:text-slate-700 mx-auto ${
                  !data?.user?.name && "btn-disabled"
                }`}
                onClick={async () => {
                  lender?.lender === data?.user?.name &&
                    (await restrictLendersNode(lender?.lnodeId as number));
                }}
                disabled={!data?.user?.name}
              >
                restrict
              </button>
            )}
          </div>
        ) : (
          <form onSubmit={onSubmit} className="w-full flex flex-col mt-1">
            {errors.collateralAmount && (
              <span className="mx-auto text-red-500 mb-2">
                This field is required
              </span>
            )}
            {lender?.lender && (
              <div className="inline-flex gap-2 items-center my-2">
                <div>
                  <p className="text-slate-500 dark:text-red-100">
                    collateral:
                  </p>
                </div>
                <Controller
                  control={control}
                  name="collateralId"
                  defaultValue={3}
                  render={({
                    field: { onChange, onBlur, value, name, ref },
                    fieldState: { isTouched, isDirty, error },
                    formState,
                  }) => (
                    <select
                      className="select select-ghost"
                      onChange={(val) => onChange(val.target.value)}
                    >
                      <option defaultValue={3} value={3}>
                        Evmos
                      </option>
                      <option value={0}>Atom</option>
                      <option value={1}>Weth</option>
                      <option value={2}>DIA</option>
                    </select>
                  )}
                />
                <input
                  type="text"
                  placeholder="amount"
                  className="input w-full p-2"
                  {...register("collateralAmount", { required: true })}
                />
              </div>
            )}
            {lender?.lender && (
              <div className="inline-flex justify-between my-2">
                <div>
                  <p className="text-slate-500 dark:text-red-100">
                    tenure (Days):
                  </p>
                </div>
                <div>
                  <Controller
                    control={control}
                    name={"tenure"}
                    defaultValue={0}
                    render={({
                      field: { onChange, onBlur, value, name, ref },
                      fieldState: { isTouched, isDirty, error },
                      formState,
                    }) => (
                      <select
                        className="select select-ghost w-24"
                        {...register("tenure")}
                        onChange={(val) => onChange(val.target.value)}
                      >
                        <option defaultValue={0} value={0}>
                          30
                        </option>
                        <option value={1}>60</option>
                        <option value={2}>90</option>
                      </select>
                    )}
                  />
                </div>
              </div>
            )}
            <button
              className={`btn btn-link lowercase text-teal-600 disabled:text-slate-700 mx-auto ${
                !data?.user?.name && "btn-disabled"
              }`}
              type="submit"
              disabled={!data?.user?.name}
            >
              fill order
            </button>
          </form>
        )}
      </div>
    </div>
  );
};

export default LoanCard;
