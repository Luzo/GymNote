//
//  Optional+unwrap.swift
//  GymNote
//
//  Created by Lubos Lehota on 30/12/2024.
//

extension Optional {
  func unwrap() throws -> Wrapped {
    guard let value = self else {
      throw OptionalUnwrapError.nilValue
    }

    return value
  }
}

enum OptionalUnwrapError: Error {
  case nilValue
}

