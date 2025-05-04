//
//  ExtractedReport.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

import Exercise
import Foundation
import Dependencies
import Utils

public struct ExtractedReport: Equatable {
  public var date: Date
  public var exercise: Exercise?
  public var repetitions: Int?
  public var weight: Double?
  public var weightUnit: UnitMass?

  public init(date: Date, exercise: Exercise? = nil, repetitions: Int? = nil, weight: Double? = nil, weightUnit: UnitMass? = nil) {
    self.date = date
    self.exercise = exercise
    self.repetitions = repetitions
    self.weight = weight
    self.weightUnit = weightUnit
  }
}

extension ExtractedReportExternal: DomainMappable {

  func toDomainModel() -> ExtractedReport {
    @Dependency(\.date.now) var today
    let dateFormatter = ISO8601DateFormatter()
    let convertedDate = date.flatMap(dateFormatter.date(from:)) ?? today
    let exercise = exercise.flatMap(Exercise.init(rawValue:))

    return .init(
      date: convertedDate,
      exercise: exercise,
      repetitions: repetitions,
      weight: weight,
      weightUnit: weightUnit.map(UnitMass.init(symbol:))
    )
  }
}
