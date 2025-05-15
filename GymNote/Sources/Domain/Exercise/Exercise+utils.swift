//
//  Exercise+utils.swift
//  GymNote
//
//  Created by Lubos Lehota on 04/05/2025.
//

import SwiftUI

public extension Binding {

  func toStringBinding(restrictedTo allowedValues: [Exercise]) -> Binding<String> where Value == Optional<Exercise> {
    Binding<String>(
      get: {
        if let value = allowedValues.first(where: { $0.rawValue == self.wrappedValue?.rawValue }) {
          return value.rawValue
        } else {
          return ""
        }
      },
      set: { newValue in
        self.wrappedValue = allowedValues.first(where: { $0.rawValue == newValue })
      }
    )
  }
}
