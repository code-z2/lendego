import React, { FC, Suspense, use, useEffect, useState } from "react";
import { useSession } from "next-auth/react";
import Seed from "../Blockies/Seed";
import { formatAddress } from "../../utils/formatAddress";
import CopyButton from "../Buttons/CopyButton";
import { getUserBalances } from "../../lib/data";
import { IBalance } from "../../lib/types";
import Image from "next/image";

const ProfileHeader: FC<{ address: string }> = ({ address }) => {
  const [balances, setBalances] = useState<IBalance[]>();
  const { data } = useSession();
  const queryBalances = async () =>
    setBalances(await getUserBalances("9000", data?.user?.name as string));
  // const balances = use(getUserBalances("9000", address));
  useEffect(() => {
    queryBalances();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const renderBalances = (): JSX.Element[] | undefined => {
    return balances
      ?.filter((el) => !el.total)
      ?.map((el, id) => {
        return (
          <div className="btn gap-2 py-0" key={id}>
            <Image
              className="mask mask-hexagon w-8 h-8"
              src={`/${el?.symbol}.svg`}
              alt={`${el?.symbol}`}
              width={0}
              height={0}
            />
            {el?.symbol}
            <div className="badge bg-primary">
              {el?.amount?.toLocaleString("en-US", {
                maximumFractionDigits: 5,
              })}
            </div>
          </div>
        );
      });
  };
  return (
    <div className="card bg-neutral text-primary-content h-36 pt-16">
      <div className="card-body p-0 pb-2 bg-gray-700 rounded-b-2xl flex-row">
        <div className="w-16 h-16 mask mask-hexagon -translate-y-6 ml-3">
          {Seed(address, 3, 20)}
        </div>
        <div className="overflow-x-hidden">
          <div className="font-bold p-2">
            {formatAddress(address)}{" "}
            <span>
              <CopyButton text={address} />
            </span>
          </div>
          <div className="flex gap-2 overflow-x-auto">
            {data?.user?.name === address && renderBalances()}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfileHeader;
