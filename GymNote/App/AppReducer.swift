//
//  AppReducer.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var textToTokenize: String = ""
  }

  enum Action: ViewAction {
    case view(View)

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
        print(state.textToTokenize)
        return .none

      case .view:
        return .none
      }
    }
  }
}
