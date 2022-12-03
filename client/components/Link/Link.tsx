import React from "react";
import { useSession } from "next-auth/react";
import Link from "next/link";

const Linkto = ({ to }: { to?: "profile" }) => {
  const { data } = useSession();
  if (to === "profile")
    return (
      <div>
        <Link
          className="link link-hover inline-flex gap-2"
          href={`/address/${data?.user?.name}`}
        >
          <span>
            <svg
              className="w-4 h-4"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fillRule="evenodd"
                d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                clipRule="evenodd"
              ></path>
            </svg>
          </span>
          Profile
        </Link>
      </div>
    );
  return (
    <div className="flex text-base font-bold">
      <h2>
        <Link className="link text-blue-400" href="/create/new/lend">
          provide a loan
        </Link>
      </h2>
      <div className="divider divider-horizontal"></div>
      <h2>
        <Link className="link text-blue-400" href="/create/new/borrow">
          request for loan
        </Link>
      </h2>
    </div>
  );
};

export default Linkto;
