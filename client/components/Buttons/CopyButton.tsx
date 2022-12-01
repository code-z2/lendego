import React from "react";

const CopyButton = ({ text }: { text: string }) => {
  return (
    <span>
      <button className="" onClick={() => navigator.clipboard.writeText(text)}>
        <svg
          className="w-4 h-4"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path d="M7 9a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2H9a2 2 0 01-2-2V9z"></path>
          <path d="M5 3a2 2 0 00-2 2v6a2 2 0 002 2V5h8a2 2 0 00-2-2H5z"></path>
        </svg>
      </button>
    </span>
  );
};

export default CopyButton;
