import Blockies from "react-blockies";

const Seed = (address: string) => {
  return (
    <Blockies
      seed={address.toLowerCase()}
      scale={3}
      className="identicon"
      size={10}
    />
  );
};

export default Seed;
