import React from "react";

const Empty = () => {
  return (
    <div className="card my-5 bg-base-300">
      <div className="flex justify-center px-4 py-16 bg-base-200">
        <span>
          <svg
            className="w-6 h-6"
            fill="currentColor"
            viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fillRule="evenodd"
              d="M5 3a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2V5a2 2 0 00-2-2H5zm0 2h10v7h-2l-1 2H8l-1-2H5V5z"
              clipRule="evenodd"
            ></path>
          </svg>
        </span>
        No Items
      </div>
    </div>
  );
};

export default Empty;
