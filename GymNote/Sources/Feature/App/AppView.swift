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
    @Dependency(\.modelContainer) var modelContainer

    var body: some View {
      ListView(store: store)
        .modelContainer(modelContainer)
    }
  }

  @ViewAction(for: AppFeature.self)
  struct ListView: View {
    @Bindable var store: StoreOf<AppFeature>
    @Query private var records: [ExerciseRecord]

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
            ForEach(ExerciseGroup.allCases, id: \.rawValue) { muscleGroup in
              let filteredExercises = records.filter { $0.exercise.group == muscleGroup }
              let groupedExercises = Dictionary(grouping: filteredExercises, by: { $0.exercise.rawValue })

              // TODO: style better + hide empty sections
              Section(header: Text(muscleGroup.rawValue)) {
                ForEach(groupedExercises.keys.sorted(), id: \.self) { exerciseName in
                  let items = groupedExercises[exerciseName] ?? []

                  Section(
                    content: {
                      ForEach(items) { item in
                        HStack {
                          Text(item.date, style: .date)
                          Text(item.weight.formatted(.measurement(width: .narrow)))
                        }
                      }
                    },
                    header: {
                      Text(exerciseName)
                        .bold()
                    },
                    footer: {
                      EmptyView()
                    }
                  )
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
