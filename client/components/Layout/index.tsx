import React, { FC, PropsWithChildren } from "react";
import Nav from "./Navigation/Navbar";
import Footer from "./Footer.tsx";

const LayoutComponent: FC<PropsWithChildren> = ({ children }) => {
  return (
    <div>
      <Nav />
      <div className="mx-auto px-5 py-10 container relative min-h-[65vh]">
        {children}
      </div>
      <Footer />
    </div>
  );
};

export default LayoutComponent;
