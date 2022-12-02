import React, { FC, useState } from "react";
import { IPagination } from "../../lib/types";

const Pagination: FC<IPagination> = (props) => {
  const [current, setCurrent] = useState(1);
  const goBack = () => {
    if (current > 1) {
      setCurrent(current - 1);
      props.callBack(props.pagination - 20);
    }
  };

  const goForward = () => {
    if (props.maxLength > props.pagination + 20) {
      props.callBack(props.pagination + 20);
      setCurrent(current + 1);
    }
  };
  return (
    <div className="btn-group mt-20 mx-auto">
      <button className="btn" onClick={goBack}>
        «
      </button>
      <button className="btn">{current}</button>
      <button className="btn" onClick={goForward}>
        »
      </button>
    </div>
  );
};

export default Pagination;
