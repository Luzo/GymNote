//
//  ContentView.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//
import ComposableArchitecture
import SwiftUI

extension AppFeature {
  struct MainView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
      Form {
        Section {
          Text("\(store.count)")
        }

        Section {
          Button("Do nothing") { store.send(.nothing) }
        }

        if let fact = store.numberFact {
          Text(fact)
        }
      }
    }
  }
}

#Preview {
  AppFeature.MainView(
    store: .init(initialState: .init(), reducer: AppFeature.init))
}
