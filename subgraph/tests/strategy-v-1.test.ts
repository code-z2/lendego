import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { BigInt, Address } from "@graphprotocol/graph-ts"
import { ErrorLogging } from "../generated/schema"
import { ErrorLogging as ErrorLoggingEvent } from "../generated/StrategyV1/StrategyV1"
import { handleErrorLogging } from "../src/strategy-v-1"
import { createErrorLoggingEvent } from "./strategy-v-1-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let reason = "Example string value"
    let newErrorLoggingEvent = createErrorLoggingEvent(reason)
    handleErrorLogging(newErrorLoggingEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("ErrorLogging created and stored", () => {
    assert.entityCount("ErrorLogging", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "ErrorLogging",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "reason",
      "Example string value"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
