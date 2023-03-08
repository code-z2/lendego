import { gql } from "@apollo/client";

const BORROWS = gql`
  query ($interest: Int, $choice: Int, $assets: BigInt) {
    borrows(
      orderBy: blockTimestamp
      orderDirection: desc
      limit: 20
      where: {
        filled: false
        choice: $choice
        interest: $interest
        assets: { _lt: $assets }
      }
    ) {
      nodeId
      borrower {
        id
      }
      filled
      choice
      interest
      assets
      ab
    }
  }
`;

export default BORROWS;