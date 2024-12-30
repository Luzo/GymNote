//
//  Result+values.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

import Foundation

extension Result {
  var value: Success? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  var error: Failure? {
    switch self {
    case .success:
      return nil
    case let .failure(failure):
      return failure
    }
  }
}
