import { NextPage } from "next";
import Link from "next/link";

const FourOFour: NextPage = () => {
  return (
    <div className="top-[50%] left-[50%] absolute -mt-[50px] mr-0 mb-0 -ml-[150px]">
      <Link href="/" className="link px-2">
        go back home.
      </Link>
      page does not exits | 404
    </div>
  );
};

export default FourOFour;
