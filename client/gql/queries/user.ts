import { gql } from "@apollo/client";

const USER_DATA = gql`
  query ($address: String) {
    user(id: $address) {
      # lends + borrows
      lends(orderBy: blockTimestamp, orderDirection: desc) {
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
      borrows(orderBy: blockTimestamp, orderDirection: desc) {
        nodeId
        borrower {
          id
        }
        assets
        amount
        interest
        choice
        tenure
        blockTimestamp
      }
      # created positions excluding pending
      positions(
        where: { isPending: false, isOpen: true, borrow_restricted: false }
        orderBy: blockTimestamp
        orderDirection: desc
      ) {
        nodeId
        isPending
        isOpen
        lend_lender {
          id
        }
        lend_choiceOfStable
        lend_interestRate
        lend_assets
        lend_filled
        lend_acceptingRequests
        lend_approvalBased
        lend_minCollateralPercentage
        borrow_borrower {
          id
        }
        borrow_collateral
        borrow_collateralIn
        borrow_maximumExpectedOutput
        borrow_tenure
        borrow_indexOfCollateral
        borrow_maxPayableInterest
        borrow_restricted
        borrow_personalised
        blockTimestamp
      }
      # paired positions excluding pending
      pairedPositions(
        where: { isPending: false, isOpen: true, borrow_restricted: false }
        orderBy: blockTimestamp
        orderDirection: desc
      ) {
        nodeId
        isPending
        isOpen
        lend_lender {
          id
        }
        lend_choiceOfStable
        lend_interestRate
        lend_assets
        lend_filled
        lend_acceptingRequests
        lend_approvalBased
        lend_minCollateralPercentage
        borrow_borrower {
          id
        }
        borrow_collateral
        borrow_collateralIn
        borrow_maximumExpectedOutput
        borrow_tenure
        borrow_indexOfCollateral
        borrow_maxPayableInterest
        borrow_restricted
        borrow_personalised
        blockTimestamp
      }
      # pending positions
      pairedPositions(
        where: { isPending: true, isOpen: true }
        orderBy: blockTimestamp
        orderDirection: desc
      ) {
        nodeId
        isPending
        isOpen
        lend_lender {
          id
        }
        lend_choiceOfStable
        lend_interestRate
        lend_assets
        lend_filled
        lend_acceptingRequests
        lend_approvalBased
        lend_minCollateralPercentage
        borrow_borrower {
          id
        }
        borrow_collateral
        borrow_collateralIn
        borrow_maximumExpectedOutput
        borrow_tenure
        borrow_indexOfCollateral
        borrow_maxPayableInterest
        borrow_restricted
        borrow_personalised
        blockTimestamp
      }
      # archived positions
      positions(
        where: { isOpen: false, borrow_restricted: false }
        orderBy: blockTimestamp
        orderDirection: desc
      ) {
        nodeId
        isPending
        isOpen
        lend_lender {
          id
        }
        lend_choiceOfStable
        lend_interestRate
        lend_assets
        lend_filled
        lend_acceptingRequests
        lend_approvalBased
        lend_minCollateralPercentage
        borrow_borrower {
          id
        }
        borrow_collateral
        borrow_collateralIn
        borrow_maximumExpectedOutput
        borrow_tenure
        borrow_indexOfCollateral
        borrow_maxPayableInterest
        borrow_restricted
        borrow_personalised
        blockTimestamp
      }
      # defaulted positions !restricted
      positions(
        where: { borrow_restricted: true }
        orderBy: blockTimestamp
        orderDirection: desc
      ) {
        nodeId
        isPending
        isOpen
        lend_lender {
          id
        }
        lend_choiceOfStable
        lend_interestRate
        lend_assets
        lend_filled
        lend_acceptingRequests
        lend_approvalBased
        lend_minCollateralPercentage
        borrow_borrower {
          id
        }
        borrow_collateral
        borrow_collateralIn
        borrow_maximumExpectedOutput
        borrow_tenure
        borrow_indexOfCollateral
        borrow_maxPayableInterest
        borrow_restricted
        borrow_personalised
        blockTimestamp
      }
    }
  }
`;


export default USER_DATA