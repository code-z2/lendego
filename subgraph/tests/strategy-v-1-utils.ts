import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  ErrorLogging,
  ItemRemoved,
  LoanExtended,
  LoanSettled,
  LoanTaken,
  NewBorrowRequest,
  NewLoan,
  UnstableItemRemoved
} from "../generated/StrategyV1/StrategyV1"

export function createErrorLoggingEvent(reason: string): ErrorLogging {
  let errorLoggingEvent = changetype<ErrorLogging>(newMockEvent())

  errorLoggingEvent.parameters = new Array()

  errorLoggingEvent.parameters.push(
    new ethereum.EventParam("reason", ethereum.Value.fromString(reason))
  )

  return errorLoggingEvent
}

export function createItemRemovedEvent(
  index: BigInt,
  burner: Address
): ItemRemoved {
  let itemRemovedEvent = changetype<ItemRemoved>(newMockEvent())

  itemRemovedEvent.parameters = new Array()

  itemRemovedEvent.parameters.push(
    new ethereum.EventParam("index", ethereum.Value.fromUnsignedBigInt(index))
  )
  itemRemovedEvent.parameters.push(
    new ethereum.EventParam("burner", ethereum.Value.fromAddress(burner))
  )

  return itemRemovedEvent
}

export function createLoanExtendedEvent(nodeId: BigInt): LoanExtended {
  let loanExtendedEvent = changetype<LoanExtended>(newMockEvent())

  loanExtendedEvent.parameters = new Array()

  loanExtendedEvent.parameters.push(
    new ethereum.EventParam("nodeId", ethereum.Value.fromUnsignedBigInt(nodeId))
  )

  return loanExtendedEvent
}

export function createLoanSettledEvent(
  nodeId: BigInt,
  borrower: Address,
  lender: Address,
  amount: BigInt
): LoanSettled {
  let loanSettledEvent = changetype<LoanSettled>(newMockEvent())

  loanSettledEvent.parameters = new Array()

  loanSettledEvent.parameters.push(
    new ethereum.EventParam("nodeId", ethereum.Value.fromUnsignedBigInt(nodeId))
  )
  loanSettledEvent.parameters.push(
    new ethereum.EventParam("borrower", ethereum.Value.fromAddress(borrower))
  )
  loanSettledEvent.parameters.push(
    new ethereum.EventParam("lender", ethereum.Value.fromAddress(lender))
  )
  loanSettledEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return loanSettledEvent
}

export function createLoanTakenEvent(
  nodeId: BigInt,
  isPending: boolean,
  lend: ethereum.Tuple,
  borrow: ethereum.Tuple
): LoanTaken {
  let loanTakenEvent = changetype<LoanTaken>(newMockEvent())

  loanTakenEvent.parameters = new Array()

  loanTakenEvent.parameters.push(
    new ethereum.EventParam("nodeId", ethereum.Value.fromUnsignedBigInt(nodeId))
  )
  loanTakenEvent.parameters.push(
    new ethereum.EventParam("isPending", ethereum.Value.fromBoolean(isPending))
  )
  loanTakenEvent.parameters.push(
    new ethereum.EventParam("lend", ethereum.Value.fromTuple(lend))
  )
  loanTakenEvent.parameters.push(
    new ethereum.EventParam("borrow", ethereum.Value.fromTuple(borrow))
  )

  return loanTakenEvent
}

export function createNewBorrowRequestEvent(
  borrower: Address,
  assets: BigInt,
  amount: BigInt,
  interest: i32,
  choice: i32,
  tenure: i32
): NewBorrowRequest {
  let newBorrowRequestEvent = changetype<NewBorrowRequest>(newMockEvent())

  newBorrowRequestEvent.parameters = new Array()

  newBorrowRequestEvent.parameters.push(
    new ethereum.EventParam("borrower", ethereum.Value.fromAddress(borrower))
  )
  newBorrowRequestEvent.parameters.push(
    new ethereum.EventParam("assets", ethereum.Value.fromUnsignedBigInt(assets))
  )
  newBorrowRequestEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  newBorrowRequestEvent.parameters.push(
    new ethereum.EventParam(
      "interest",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(interest))
    )
  )
  newBorrowRequestEvent.parameters.push(
    new ethereum.EventParam(
      "choice",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(choice))
    )
  )
  newBorrowRequestEvent.parameters.push(
    new ethereum.EventParam(
      "tenure",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(tenure))
    )
  )

  return newBorrowRequestEvent
}

export function createNewLoanEvent(
  lender: Address,
  choice: i32,
  interest: i32,
  assets: BigInt,
  ab: boolean
): NewLoan {
  let newLoanEvent = changetype<NewLoan>(newMockEvent())

  newLoanEvent.parameters = new Array()

  newLoanEvent.parameters.push(
    new ethereum.EventParam("lender", ethereum.Value.fromAddress(lender))
  )
  newLoanEvent.parameters.push(
    new ethereum.EventParam(
      "choice",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(choice))
    )
  )
  newLoanEvent.parameters.push(
    new ethereum.EventParam(
      "interest",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(interest))
    )
  )
  newLoanEvent.parameters.push(
    new ethereum.EventParam("assets", ethereum.Value.fromUnsignedBigInt(assets))
  )
  newLoanEvent.parameters.push(
    new ethereum.EventParam("ab", ethereum.Value.fromBoolean(ab))
  )

  return newLoanEvent
}

export function createUnstableItemRemovedEvent(
  index: BigInt
): UnstableItemRemoved {
  let unstableItemRemovedEvent = changetype<UnstableItemRemoved>(newMockEvent())

  unstableItemRemovedEvent.parameters = new Array()

  unstableItemRemovedEvent.parameters.push(
    new ethereum.EventParam("index", ethereum.Value.fromUnsignedBigInt(index))
  )

  return unstableItemRemovedEvent
}
