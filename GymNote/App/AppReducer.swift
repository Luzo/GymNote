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
    var count = 0
    var numberFact: String?
  }

  enum Action {
    // TODO: placeholder action
    case nothing
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .nothing:
        return .none
      }
    }
  }
}
