//
//  ExerciseRecord.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

import Foundation
import SwiftData

@Model
class ExerciseRecord: Equatable {
  var date: Date
  var exercise: Exercise
  var repetitions: Int
  @Transient
  var weight: Measurement<UnitMass> {
    get { .init(value: weightNumber, unit: UnitMass.allowedOrDefaultUnit(for: weightSymbol)) }
    set { setWeight(newValue) }
  }

  private var weightNumber: Double
  private var weightSymbol: String

  init(date: Date, exercise: Exercise, repetitions: Int, weight: Measurement<UnitMass>) {
    self.date = date
    self.exercise = exercise
    self.repetitions = repetitions
    weightNumber = 0
    weightSymbol = ""
    self.weight = weight
  }

  private func setWeight(_ weight: Measurement<UnitMass>) {
    weightNumber = weight.value
    weightSymbol = weight.unit.symbol
  }
}
