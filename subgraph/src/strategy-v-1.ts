import {
  ItemRemoved as ItemRemovedEvent,
  LoanExtended as LoanExtendedEvent,
  LoanSettled as LoanSettledEvent,
  LoanTaken as LoanTakenEvent,
  NewBorrowRequest as NewBorrowRequestEvent,
  NewLoan as NewLoanEvent,
  UnstableItemRemoved as UnstableItemRemovedEvent,
  NodeDeactivated as NodeDeactivatedEvent,
} from "../generated/StrategyV1/StrategyV1";
import { Node, Borrow, Lend, User } from "../generated/schema";

import { store } from "@graphprotocol/graph-ts";

export function handleItemRemoved(event: ItemRemovedEvent): void {
  let id = event.params.index.toHexString();
  store.remove("Lend", id);
}

export function handleLoanExtended(event: LoanExtendedEvent): void {
  let entity = Node.load(event.params.nodeId.toHexString());
  if (entity) {
    entity.borrow_tenure += 15;
    entity.save();
  }
}

export function handleLoanSettled(event: LoanSettledEvent): void {
  let entity = Node.load(event.params.nodeId.toHexString());
  if (entity) {
    entity.isOpen = false;
    entity.save();
  }
}

export function handleNodeDeactivated(event: NodeDeactivatedEvent): void {
  let entity = Lend.load(event.params.nodeId.toHexString());
  if (entity) {
    entity.acceptingRequests = false;
    entity.save();
  }
}

export function handleLoanTaken(event: LoanTakenEvent): void {
  let entity = new Node(event.params.nodeId.toHexString());

  entity.nodeId = event.params.nodeId;
  entity.isPending = event.params.isPending;
  entity.isOpen = true;
  entity.lend_lender = event.params.lend.lender;
  entity.lend_choiceOfStable = event.params.lend.choiceOfStable;
  entity.lend_interestRate = event.params.lend.interestRate;
  entity.lend_assets = event.params.lend.assets;
  entity.lend_filled = event.params.lend.filled;
  entity.lend_acceptingRequests = event.params.lend.acceptingRequests;
  entity.lend_approvalBased = event.params.lend.approvalBased;
  entity.lend_minCollateralPercentage =
    event.params.lend.minCollateralPercentage;
  entity.borrow_borrower = event.params.borrow.borrower;
  entity.borrow_collateral = event.params.borrow.collateral;
  entity.borrow_collateralIn = event.params.borrow.collateralIn;
  entity.borrow_maximumExpectedOutput =
    event.params.borrow.maximumExpectedOutput;
  entity.borrow_tenure = event.params.borrow.tenure;
  entity.borrow_indexOfCollateral = event.params.borrow.indexOfCollateral;
  entity.borrow_maxPayableInterest = event.params.borrow.maxPayableInterest;
  entity.borrow_restricted = event.params.borrow.restricted;
  entity.borrow_personalised = event.params.borrow.personalised;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let lend = Lend.load(event.params.lendId.toHexString());
  if (lend) {
    lend.filled = true;
    lend.save();
  }
}

export function handleNewBorrowRequest(event: NewBorrowRequestEvent): void {
  let entity = new Borrow(event.params.index.toHexString());
  entity.nodeId = event.params.index;
  entity.borrower = event.params.borrower;
  entity.assets = event.params.assets;
  entity.amount = event.params.amount;
  entity.interest = event.params.interest;
  entity.choice = event.params.choice;
  entity.tenure = event.params.tenure;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let user = User.load(event.params.borrower);
  if (!user) {
    user = new User(event.params.borrower);
    user.save();
  }
}

export function handleNewLoan(event: NewLoanEvent): void {
  let entity = new Lend(event.params.index.toHexString());
  entity.nodeId = event.params.index;
  entity.lender = event.params.lender;
  entity.choice = event.params.choice;
  entity.interest = event.params.interest;
  entity.assets = event.params.assets;
  entity.filled = false;
  entity.acceptingRequests = true;
  entity.ab = event.params.ab;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let user = User.load(event.params.lender);
  if (!user) {
    user = new User(event.params.lender);
    user.save();
  }
}

export function handleUnstableItemRemoved(
  event: UnstableItemRemovedEvent
): void {
  let id = event.params.index.toHexString();
  store.remove("Borrow", id);
}
