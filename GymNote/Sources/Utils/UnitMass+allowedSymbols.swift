//
//  UnitMass+allowedSymbols.swift
//  GymNote
//
//  Created by Lubos Lehota on 31/12/2024.
//

import Foundation

public extension UnitMass {
  static var appAllowed: [UnitMass] { [.kilograms, .pounds] }
  static func allowedOrDefaultUnit(for weightSymbol: String) -> UnitMass {
    appAllowed.first { $0.symbol == weightSymbol } ?? appAllowed[0]
  }
}
