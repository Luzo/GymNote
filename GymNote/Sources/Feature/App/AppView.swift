//
//  ContentView.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import ComposableArchitecture
import SwiftData
import SwiftUI

extension AppFeature {
  @ViewAction(for: AppFeature.self)
  struct MainView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
      ListView(store: store)
        .onAppear { send(.onAppear) }
    }
  }

  @ViewAction(for: AppFeature.self)
  struct ListView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
      Group {
        Form {
          Section {
            TextField("Add text to process", text: $store.input)
          }

          Section {
            Button("Process text") { send(.extractReport) }
          }

          List {
            ForEach(store.records, id: \.self) { muscleGroup in
              Section(header: Text(muscleGroup.name)) {
                ForEach(muscleGroup.sections, id: \.self) { section in
                  Text(section.name)
                    .bold()

                  ForEach(section.records) { item in
                    HStack {
                      Text(item.date, style: .date)
                      Text(item.weight.formatted(.measurement(width: .narrow)))
                    }
                  }
                }
              }
            }
          }
        }
        .sheet(
          item: $store.scope(state: \.newRecordState, action: \.newRecord)
        ) { store in
          NewRecordFeature.MainView(store: store)
        }
      }
    }
  }
}

#Preview {
  AppFeature.MainView(
    store: .init(initialState: .init(), reducer: AppFeature.init))
}
