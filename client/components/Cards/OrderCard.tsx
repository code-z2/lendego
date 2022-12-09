import React from "react";
import { useForm, Controller } from "react-hook-form";
import { useSession } from "next-auth/react";
import Seed from "../Blockies/Seed";
import { formatAddress } from "../../utils/formatAddress";
import useActions from "../../hooks/useActions";
import { IBorrow, ILend } from "../../lib/types";

const OrderCard = ({ node }: { node: string }) => {
  const { data } = useSession();
  const { createStablePosition, createUnstablePosition } = useActions({
    chainId: 9000,
  });
  const {
    register,
    control,
    handleSubmit,
    watch,
    reset,
    formState: { errors },
  } = useForm<ILend | IBorrow>();

  const onSubmit = handleSubmit(async (data) => {
    console.log(data);
    if (node === "borrow") {
      const percentage =
        parseFloat((data as IBorrow).collateralAmount.toString()) * 12;
      if (
        !(
          percentage >
          1.3 * parseFloat((data as IBorrow).maximumExpectedOutput.toString())
        )
      ) {
        alert("insufficient collateral");
        return;
      }
    }

    node === "lend"
      ? await createStablePosition(data as ILend)
      : await createUnstablePosition(data as IBorrow);

    reset();
  });

  return (
    <form onSubmit={onSubmit} className="w-full flex flex-col mt-1">
      <div className="card card-compact md:w-[28rem] bg-base-100 md:shadow-xl min-h-[14rem] hover:shadow-md p-10 bg-opacity-50 glass m-auto relative">
        <div className="absolute w-72 h-72 top-15 left-20 bg-blue-200 rounded-md mix-blend-multiply filter blur-2xl opacity-50"></div>
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
          {(errors as ILend).assets && (
            <span className="mx-auto text-red-500 mb-2">
              please enter a valid amount
            </span>
          )}
          <div className="inline-flex gap-4 items-center">
            <div>
              <p className="text-slate-500 dark:text-red-100">Amount:</p>
            </div>
            <Controller
              control={control}
              name="stableId"
              defaultValue={0}
              render={({
                field: { onChange, onBlur, value, name, ref },
                fieldState: { isTouched, isDirty, error },
                formState,
              }) => (
                <select
                  className="select select-ghost"
                  onChange={(val) => onChange(val.target.value)}
                >
                  <option defaultValue={0} value={0}>
                    USDC
                  </option>
                  {node === "lend" && <option value={1}>DAI</option>}
                  {node === "lend" && <option value={2}>USDT</option>}
                  {node === "lend" && <option value={3}>BUSD</option>}
                  {node === "lend" && <option value={4}>FRAX</option>}
                </select>
              )}
            />

            <input
              type="text"
              placeholder="amount"
              className="input w-full p-2"
              {...register(
                node === "lend" ? "assets" : "maximumExpectedOutput",
                { required: true }
              )}
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
          {/* inerest rate for lender|borrower */}
          {(errors as ILend).interestRate && (
            <span className="mx-auto text-red-500 mb-2">
              please add an interest rate (0 - 15%)
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
                {...register(
                  node === "lend" ? "interestRate" : "maxPayableInterest",
                  { required: true, max: 15 }
                )}
              />
            </div>
          </div>
          {/* collateral borrower */}
          {(errors as IBorrow).collateralAmount && (
            <span className="mx-auto text-red-500 mb-2">
              enter at least 125% of collateral
            </span>
          )}
          {node === "borrow" && (
            <div className="inline-flex gap-4 items-center">
              <div>
                <p className="text-slate-500 dark:text-red-100">collateral:</p>
              </div>
              <Controller
                control={control}
                name={"collateralId"}
                defaultValue={3}
                render={({
                  field: { onChange, onBlur, value, name, ref },
                  fieldState: { isTouched, isDirty, error },
                  formState,
                }) => (
                  <select
                    className="select select-ghost"
                    {...register("collateralId")}
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
