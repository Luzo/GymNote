//
//  ContentView.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture
import SwiftUI

extension AppFeature {
  @ViewAction(for: AppFeature.self)
  struct MainView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
      Form {
        Section {
          TextField("Add text to process", text: $store.textToTokenize)
        }

        Section {
          Button("Process text") { send(.tokenizeTapped) }
        }
      }
    }
  }
}

#Preview {
  AppFeature.MainView(
    store: .init(initialState: .init(), reducer: AppFeature.init))
}
