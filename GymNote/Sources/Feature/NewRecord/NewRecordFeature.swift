//
//  NewRecordFeature.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import CasePaths
import ComposableArchitecture
import Foundation
import Dependencies
import Exercise
import Service
import SwiftData

@Reducer
public struct NewRecordFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    let allowedValuesWeight: [UnitMass] = UnitMass.appAllowed
    let allowedValuesExercise: [Exercise] = Exercise.allCases

    var date: Date
    var exercise: Exercise?
    var repetitions: Int?
    var weight: Double?
    var weightUnit: UnitMass?

    public init(extractedReport: ExtractedReport) {
      self.date = extractedReport.date
      self.exercise = extractedReport.exercise
      self.repetitions = extractedReport.repetitions
      self.weight = extractedReport.weight
      self.weightUnit = extractedReport.weightUnit.flatMap { unit in
        allowedValuesWeight.first { $0.symbol == unit.symbol }
      }
    }
  }

  public enum Action: ViewAction {
    case recordSaved
    case view(ViewAction)

    @CasePathable
    public enum ViewAction: BindableAction, Sendable {
      case binding(BindingAction<State>)
      case finalizeReport
    }
  }

  public var body: some ReducerOf<Self> {
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

        @Dependency(\.uuid) var uuid

        let record = ExerciseRecord(
          uuid: uuid(),
          date: state.date,
          exercise: exercise,
          repetitions: repetitions,
          weight: Measurement<UnitMass>.init(value: weight, unit: weightUnit)
        )

        @Dependency(\.exerciseRecordContainerService) var exerciseRecordContainerService

        return .run { send in
          try await exerciseRecordContainerService.save(record)
          await send(.recordSaved)
        }

      case .view:
        return .none
      }
    }
  }
}
