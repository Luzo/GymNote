//
//  AppFeature.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture
import NaturalLanguage

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var input: String = "Tuesday I did 20 push ups with 10 kilos"
    @Presents var newRecordState: NewRecordFeature.State?
  }

  enum Action: ViewAction {
    case view(View)
    case receivedAIResponse(Result<ExtractedReport, AIResponseError>)
    case newRecord(PresentationAction<NewRecordFeature.Action>)


    @CasePathable
    public enum View: BindableAction, Sendable {
      case binding(BindingAction<State>)
      case extractReport
    }
  }

  var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Reduce { state, action in
      switch action {
      case .view(.extractReport):
        let text = state.input

        return .run { send in
          @Dependency(\.groqService.extractReport) var extractReport
          let response = await (extractReport(text))
          await send(.receivedAIResponse(response))
        }

      case let .receivedAIResponse(.success(response)):
        state.newRecordState = .init(extractedReport: response)
        return .none

      case let .receivedAIResponse(.failure(error)):
        // Add retry with the same or add new
        print(error)
        return .none

      case .view,
        .newRecord:

        return .none
      }
    }
    .ifLet(\.$newRecordState, action: \.newRecord) {
      NewRecordFeature()
    }
  }
}
