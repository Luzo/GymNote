//
//  AppFeature.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture
import NaturalLanguage
import SwiftData

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var input: String = "Tuesday I did 20 push ups with 10 kilos"
    var records: [ExerciseMuscleGroupSection] = []

    @Presents var newRecordState: NewRecordFeature.State?
  }

  enum Action: ViewAction {
    case view(ViewAction)
    case receivedAIResponse(Result<ExtractedReport, AIResponseError>)
    case newRecord(PresentationAction<NewRecordFeature.Action>)
    case receivedSavedRecords([ExerciseRecord])
    case recordsChanged

    @CasePathable
    public enum ViewAction: BindableAction, Sendable {
      case onAppear
      case binding(BindingAction<State>)
      case extractReport
    }
  }

  enum Cancellable {
    case observeRecordChange
  }

  var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        return handleViewAction(viewAction, state: state)

      case let .receivedAIResponse(.success(response)):
        state.newRecordState = .init(extractedReport: response)
        return .none

      case let .receivedAIResponse(.failure(error)):
        // Add retry with the same or add new
        print(error)
        return .none

      case let .receivedSavedRecords(records):
        state.records = ExerciseGroup.allCases.compactMap { muscleGroup in
          let filteredExercises = records.filter { $0.exercise.group == muscleGroup }

          guard !filteredExercises.isEmpty else { return nil }

          let groupedExercises = Dictionary(grouping: filteredExercises, by: { $0.exercise.rawValue })
          let sections = groupedExercises.keys.sorted().compactMap { exerciseName -> ExerciseSection? in
            guard let items = groupedExercises[exerciseName] else { return nil }
            return ExerciseSection(name: exerciseName, records: items)
          }

          return ExerciseMuscleGroupSection(name: muscleGroup.rawValue, sections: sections)
        }

        return .none

      case .recordsChanged:
        return fetchRecords()

      case .newRecord:
        return .none
      }
    }
    .ifLet(\.$newRecordState, action: \.newRecord) {
      NewRecordFeature()
    }
  }
}

private extension AppFeature {
  func handleViewAction(_ action: Action.ViewAction, state: State) -> Effect<Action> {
    switch action {
    case .onAppear:
      return .merge(
        fetchRecords(),
        observeRecordChanges()
      )

    case .extractReport:
      let text = state.input

      return .run { send in
        @Dependency(\.groqService.extractReport) var extractReport
        let response = await (extractReport(text))
        await send(.receivedAIResponse(response))
      }

    case .binding:
      return .none
    }
  }

  func fetchRecords() -> Effect<Action> {
    @Dependency(\.modelContainer) var modelContainer

    return .run { send in
      try await MainActor.run {
        let context = modelContainer.mainContext
        send(.receivedSavedRecords(try context.fetch(FetchDescriptor<ExerciseRecord>())))
      }
    }
  }

  func observeRecordChanges() -> Effect<Action> {
    return .run { send in
      NotificationCenter.default.addObserver(
        forName: ModelContext.didSave,
        object: nil,
        queue: .main
      ) { _ in
        Task {
          await send(.recordsChanged)
        }
      }
    }
    .cancellable(id: Cancellable.observeRecordChange, cancelInFlight: true)
  }
}
