//
//  NewRecordView.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

import ComposableArchitecture
import SwiftUI

extension NewRecordFeature {
  @ViewAction(for: AppFeature.self)
  struct MainView: View {
    @Bindable var store: StoreOf<NewRecordFeature>

    var body: some View {
      VStack {
      Text("New Gym Record")
        Form {
          Section {
            DatePicker("Date of exercise", selection: $store.date, displayedComponents: .date)

            Picker(
              "Exercise",
              selection: $store.exercise.toStringBinding(restrictedTo: store.allowedValuesExercise)
            ) {
              Text("Select weight unit").tag("")
              ForEach(store.allowedValuesExercise, id: \.rawValue) { value in
                Text(value.rawValue).tag(value.rawValue)
              }
            }

            LabeledContent("Repetitions") {
              TextField("Add repetitions", text: $store.repetitions.toStringBinding())
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
            }
            LabeledContent("Used weight") {
              TextField("Add weight", text: $store.weight.toStringBinding())
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
            }
            Picker(
              "Weight unit",
              selection: $store.weightUnit.toStringBinding(restrictedTo: store.allowedValuesWeight)
            ) {
              Text("Select weight unit").tag("")
              ForEach(store.allowedValuesWeight, id: \.self) { value in
                Text(value.symbol).tag(value.symbol)
              }
            }
          }

          Section {
            Button("Save this record") { send(.finalizeReport) }
              .buttonStyle(.borderedProminent)
          }
        }
          .scrollContentBackground(.hidden)
      }
    }
  }
}

#Preview {
  NewRecordFeature.MainView(
    store: .init(
      initialState: .init(extractedReport: ExtractedReport(date: .init(), exercise: .biceps(.chinup))),
      reducer: NewRecordFeature.init)
  )
}
