//
//  NumericValue+StringBinding.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

import SwiftUI

public extension Binding {
  func toStringBinding<Wrapped: LosslessStringConvertible>() -> Binding<String> where Value == Optional<Wrapped> {
    Binding<String>(
      get: {
        if let value = self.wrappedValue {
          return String(value)
        } else {
          return ""
        }
      },
      set: { newValue in
        if let numericValue = Wrapped(newValue) {
          self.wrappedValue = numericValue
        } else if newValue.isEmpty {
          self.wrappedValue = nil
        }
      }
    )
  }
}

public extension Binding {
  func unwrapOptionalToEmpty() -> Binding<String> where Value == Optional<String> {
    Binding<String>(
      get: {
        if let value = self.wrappedValue {
          return String(value)
        } else {
          return ""
        }
      },
      set: { newValue in
        self.wrappedValue = newValue.nilIfEmpty
      }
    )
  }
}

public extension Binding {
  func toStringBinding<Wrapped: Unit>(restrictedTo allowedValues: [Wrapped]) -> Binding<String> where Value == Optional<Wrapped> {
    Binding<String>(
      get: {
        if let value = allowedValues.first(where: { $0.symbol == self.wrappedValue?.symbol }) {
          return value.symbol
        } else {
          return ""
        }
      },
      set: { newValue in
        self.wrappedValue = allowedValues.first(where: { $0.symbol == newValue })
      }
    )
  }
}
