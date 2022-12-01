import { isAddress } from "ethers/lib/utils.js";

export const formatAddress = (address: string): string => {
  const n: number = 6;
  if (isAddress(address)) {
    return `${address.substring(0, n)}...${address.substring(
      address.length - (n - 1),
      address.length
    )}`;
  }
  return "";
};
