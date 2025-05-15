//
//  ExerciseRecord.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

import Foundation
import Utils
import SwiftData

@Model
public class ExerciseRecord: Equatable, Identifiable {
  public var id: String
  public var date: Date
  public var exercise: Exercise
  public var repetitions: Int
  @Transient
  public var weight: Measurement<UnitMass> {
    get { .init(value: weightNumber, unit: UnitMass.allowedOrDefaultUnit(for: weightSymbol)) }
    set { setWeight(newValue) }
  }

  private var weightNumber: Double
  private var weightSymbol: String

  public init(uuid: UUID, date: Date, exercise: Exercise, repetitions: Int, weight: Measurement<UnitMass>) {
    self.id = uuid.uuidString
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

  public static func == (lhs: ExerciseRecord, rhs: ExerciseRecord) -> Bool {
    return lhs.id == rhs.id &&
    lhs.date == rhs.date &&
    lhs.exercise == rhs.exercise &&
    lhs.repetitions == rhs.repetitions &&
    lhs.weightNumber == rhs.weightNumber &&
    lhs.weightSymbol == rhs.weightSymbol
  }
}
