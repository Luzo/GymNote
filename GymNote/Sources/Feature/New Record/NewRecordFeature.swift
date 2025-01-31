//
//  NewRecordFeature.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture
import Foundation
import Dependencies
import SwiftData

@Reducer
struct NewRecordFeature {
  @ObservableState
  struct State: Equatable {
    let allowedValuesWeight: [UnitMass] = UnitMass.appAllowed
    let allowedValuesExercise: [Exercise] = Exercise.allCases

    var finalizedReport: ExerciseRecord?
    var date: Date
    var exercise: Exercise?
    var repetitions: Int?
    var weight: Double?
    var weightUnit: UnitMass?

    init(extractedReport: ExtractedReport) {
      self.date = extractedReport.date
      self.exercise = extractedReport.exercise
      self.repetitions = extractedReport.repetitions
      self.weight = extractedReport.weight
      self.weightUnit = extractedReport.weightUnit.flatMap { unit in
        allowedValuesWeight.first { $0.symbol == unit.symbol }
      }
    }
  }

  enum Action: ViewAction {
    case recordSaved
    case view(View)

    @CasePathable
    public enum View: BindableAction, Sendable {
      case binding(BindingAction<State>)
      case finalizeReport
    }
  }

  var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Reduce { state, action in
      switch action {
      case .recordSaved:
        @Dependency(\.dismiss) var dismiss
        return .run { _ in await dismiss() }

      case .view(.finalizeReport):
        guard
          let exercise = state.exercise,
          let repetitions = state.repetitions,
          let weight = state.weight,
          let weightUnit = state.weightUnit
        else {
          // TODO: show error
          return .none
        }

        let record = ExerciseRecord(
          date: state.date,
          exercise: exercise,
          repetitions: repetitions,
          weight: Measurement<UnitMass>.init(value: weight, unit: weightUnit)
        )

        @Dependency(\.modelContainer) var modelContainer

        return .run { send in
          try await MainActor.run {
            let context = modelContainer.mainContext
            context.insert(record)
            try context.save()

            send(.recordSaved)
          }
        }

      case .view:
        return .none
      }
    }
  }
}
