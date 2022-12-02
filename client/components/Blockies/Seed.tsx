import Blockies from "react-blockies";

const Seed = (address: string, scale: number, size: number) => {
  return (
    <Blockies
      seed={address.toLowerCase()}
      scale={scale}
      className="identicon"
      size={size}
    />
  );
};

export default Seed;
