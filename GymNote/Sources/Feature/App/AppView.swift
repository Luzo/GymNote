//
//  ContentView.swift
//  GymNote
//
//  Created by Lubos Lehota on 26/12/2024.
//

import CasePaths
import ComposableArchitecture
import SwiftData
import SwiftUI

extension AppFeature {
  @ViewAction(for: AppFeature.self)
  public struct MainView: View {
    @Bindable public var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
      self.store = store
    }

    public var body: some View {
      ZStack(alignment: .bottom) {
        ListView(store: store)
          .onAppear { send(.onAppear) }

        Button(store.isRecognizing == false ? "Start recording" : "Stop recording") {
          send(.startStopRecording)
        }
      }
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
                    .swipeActions {
                      Button {
                        send(.removeRecord(item.id))
                      } label: {
                        Image(systemName: "xmark.bin.circle")
                      }
                      .tint(Color.red)
                    }
                  }
                }
              }
            }
          }
        }
//        .sheet(
//          item: $store.scope(state: \.newRecordState, action: \.newRecord)
//        ) { store in
//          NewRecordFeature.MainView(store: store)
//        }
      }
    }
  }
}

#Preview {
  AppFeature.MainView(
    store: .init(initialState: .init(), reducer: AppFeature.init))
}
