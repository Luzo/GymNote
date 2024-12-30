//
//  NewRecordFeature.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture
import Foundation
import Dependencies

@Reducer
struct NewRecordFeature {
  @ObservableState
  struct State: Equatable {
    let allowedValues: [UnitMass] = [.kilograms, .pounds]
    var finalizedReport: NewRecord?
    var date: Date
    var exercise: String?
    var repetitions: Int?
    var weight: Double?
    var weightUnit: UnitMass?

    init(extractedReport: ExtractedReport) {
      self.date = extractedReport.date
      self.exercise = extractedReport.exercise
      self.repetitions = extractedReport.repetitions
      self.weight = extractedReport.weight
      self.weightUnit = extractedReport.weightUnit.flatMap {
        allowedValues.contains($0) ? $0 : nil
      }
    }
  }

  enum Action: ViewAction {
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

        state.finalizedReport = NewRecord(
          date: state.date,
          // TODO: convert to known Exercise if possible
          exercise: .unknown(exercise),
          repetitions: repetitions,
          weight: Measurement<UnitMass>.init(value: weight, unit: weightUnit)
        )

        @Dependency(\.dismiss) var dismiss
        return .run { _ in await dismiss() }

      case .view:
        return .none
      }
    }
  }
}
