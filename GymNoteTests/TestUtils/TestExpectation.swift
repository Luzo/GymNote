//
//  Expectation.swift
//  GymNote
//
//  Created by Lubos Lehota on 30/12/2024.
//

actor TestExpectationActor {
  let allowMultimpleFulfillments: Bool
  private var wasFulfilled = false
  private var error: ExpectationError?

  init(allowMultimpleFulfillments: Bool = false) {
    self.allowMultimpleFulfillments = allowMultimpleFulfillments
  }

  func fulfill() -> Void {
    if wasFulfilled && !allowMultimpleFulfillments {
      error = ExpectationError.multipleFulfillments
    } else {
      wasFulfilled = true
    }
  }

  func checkIfFulfilled() throws -> Bool {
    guard let error else {
      return wasFulfilled
    }

    throw error
  }
}

enum ExpectationError: Error {
  case multipleFulfillments
}

struct TestExpectation {
  private let actor: TestExpectationActor

  init(allowMultimpleFulfillments: Bool = false) {
    actor = .init(allowMultimpleFulfillments: allowMultimpleFulfillments)
  }

  func checkIfFulfilled() async throws -> Bool {
    try await actor.checkIfFulfilled()
  }

  func fulfill() {
    Task {
      await actor.fulfill()
    }
  }
}
