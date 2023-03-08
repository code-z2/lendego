import { gql } from "@apollo/client";

const LENDS = gql`
  query ($interest: Int, $choice: Int, $assets: BigInt) {
    lends(
      orderBy: blockTimestamp
      orderDirection: desc
      limit: 20
      where: {
        filled: false
        choice: $choice
        interest: $interest
        assets: { _lt: s$assets }
      }
    ) {
      nodeId
      lender {
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


export default LENDS;