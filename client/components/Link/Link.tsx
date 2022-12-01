import React from "react";
import { useSession } from "next-auth/react";

const Link = ({ to }: { to?: "profile" }) => {
  const { data } = useSession();
  if (to === "profile")
    return (
      <div>
        <a
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
        </a>
      </div>
    );
  return (
    <div className="flex text-base font-bold">
      <h2>
        <a className="link link-hover" href="/create/new/lend">
          Provide Loan
        </a>
      </h2>
      <div className="divider divider-horizontal"></div>
      <h2>
        <a className="link link-hover" href="/create/new/borrow">
          Request Loan
        </a>
      </h2>
    </div>
  );
};

export default Link;
