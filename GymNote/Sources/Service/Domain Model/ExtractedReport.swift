//
//  ExtractedReport.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

import Foundation
import Dependencies

struct ExtractedReport: Equatable {
  var date: Date
  var exercise: Exercise?
  var repetitions: Int?
  var weight: Double?
  var weightUnit: UnitMass?
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
