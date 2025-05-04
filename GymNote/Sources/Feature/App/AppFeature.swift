//
//  AppFeature.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import CasePaths
import ComposableArchitecture
import Dependencies
import Exercise
import NaturalLanguage
import NewRecord
import Service
import SwiftData

@Reducer
public struct AppFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var input: String = "Tuesday I did 20 push ups with 10 kilos"
    var records: [ExerciseMuscleGroupSection] = []
    var isRecognizing: Bool = false

    @Presents var newRecordState: NewRecordFeature.State?

    public init() {}
  }

  public enum Action: ViewAction {
    case view(ViewAction)
    case receivedAIResponse(Result<ExtractedReport, AIResponseError>)
    case newRecord(PresentationAction<NewRecordFeature.Action>)
    case receivedSavedRecords([ExerciseRecord])
    case recordsChanged
    case recognizedTextResult(Result<String, SpeechRecognizer.RecognizerError>)


    @CasePathable
    public enum ViewAction: BindableAction, Sendable {
      case onAppear
      case binding(BindingAction<State>)
      case extractReport
      case removeRecord(ExerciseRecord.ID)
      case startStopRecording
    }
  }

  enum Cancellable {
    case observeRecordChange
  }

  public var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        return handleViewAction(viewAction, state: &state)

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

      case let .recognizedTextResult(result):
        switch result {
        case let .success(recognizedText):
          state.input = recognizedText

        case let .failure(error):
          // TODO: Show error to user?
          print(error)
        }

        return .none
      }
    }
    .ifLet(\.$newRecordState, action: \.newRecord) {
      NewRecordFeature()
    }
  }
}

private extension AppFeature {
  func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
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

    case let .removeRecord(idToRemove):
      @Dependency(\.exerciseRecordContainerService) var exerciseRecordContainerService

      return .run { send in
        try await exerciseRecordContainerService.delete(idToRemove)
      }

    case .startStopRecording:
      state.isRecognizing.toggle()

      @Dependency(\.speechRecognizerService) var speechRecognizerService
      let isRecognizing = state.isRecognizing
      return .run { send in
        isRecognizing
        ? await send(.recognizedTextResult(await speechRecognizerService.recognizeText()))
        : await speechRecognizerService.stopRecognizing()
      }
    }
  }

  func fetchRecords() -> Effect<Action> {
    @Dependency(\.exerciseRecordContainerService) var exerciseRecordContainerService

    return .run { send in
      let records = try await exerciseRecordContainerService.fetchAll()
      await send(.receivedSavedRecords(records))
    }
  }

  func observeRecordChanges() -> Effect<Action> {
    return .run { send in
      let stream = NotificationCenter.default.notifications(named: ModelContext.didSave)

      for await _ in stream {
        await send(.recordsChanged)
      }
    }
    .cancellable(id: Cancellable.observeRecordChange, cancelInFlight: true)
  }
}
