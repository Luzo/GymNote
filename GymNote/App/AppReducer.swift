//
//  AppReducer.swift
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
    var textToTokenize: String = "Tuesday I did 20 push ups with 10 kilos"
  }

  enum Action: ViewAction {
    case view(View)
    case receivedAIResponse(Result<ExtractedReport, AIResponseError>)

    @CasePathable
    public enum View: BindableAction, Sendable {
      case binding(BindingAction<State>)
      case tokenizeTapped
    }
  }

  var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Reduce { state, action in
      switch action {
      case .view(.tokenizeTapped):
        let text = state.textToTokenize

        return .run { send in
          @Dependency(\.groqService.extractReport) var extractReport
          let response = await (extractReport(text))
          await send(.receivedAIResponse(response))
        }

      case let .receivedAIResponse(.success(response)):
        print(response)
        return .none

      case let .receivedAIResponse(.failure(error)):
        print(error)
        return .none

      case .view:
        return .none
      }
    }
  }
}

