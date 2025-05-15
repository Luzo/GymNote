//
//  NewRecordFeatureTests.swift
//  GymNote
//
//  Created by Lubos Lehota on 30/12/2024.
//

import CustomDump
import ComposableArchitecture
import Testing
@testable import GymNote

struct NewRecordFeatureTests {

  @Test
  func finalizeReportIfCompleteAndDismiss() async throws {
    let mockedExercise = Exercise.chest(.benchPress)
    let mock = ExtractedReport(date: .now, exercise: mockedExercise, repetitions: 5, weight: 100, weightUnit: .kilograms)
    let testDismissExpectation = TestExpectation()
    let testSavedExpectation = TestExpectation()

    let store = await TestStore(
      initialState: NewRecordFeature.State(extractedReport: mock),
      reducer: NewRecordFeature.init,
      withDependencies: {
        $0.uuid = .constant(.init(0))
        $0.dismiss = .init {
          testDismissExpectation.fulfill()
        }
        $0.exerciseRecordContainerService.save = { record in
          let expectedExerciseRecord = try ExerciseRecord(
            date: mock.date,
            exercise: mockedExercise,
            repetitions: mock.repetitions.unwrap(),
            weight: .init(value: mock.weight.unwrap(), unit: mock.weightUnit.unwrap())
          )
          #expect(record == expectedExerciseRecord)
          testSavedExpectation.fulfill()
        }
      }
    )

    await store.send(\.view.finalizeReport)
    await store.receive(\.recordSaved)

    #expect(try await testDismissExpectation.checkIfFulfilled())
    #expect(try await testSavedExpectation.checkIfFulfilled())
  }

  @Test
  func dontFinalizeReportIfIncomplete() async throws {
    let mock = ExtractedReport(date: .now, exercise: .chest(.benchPress), weight: 100, weightUnit: .kilograms)

    let store = await TestStore(
      initialState: NewRecordFeature.State(extractedReport: mock),
      reducer: NewRecordFeature.init
    )

    await store.send(\.view.finalizeReport)
  }

  @Test
  func dontFinalizeReportIfInvalidData() async throws {
    let mock = ExtractedReport(date: .now, exercise: .chest(.benchPress), repetitions: 5, weight: 100, weightUnit: .carats)

    let store = await TestStore(
      initialState: NewRecordFeature.State(extractedReport: mock),
      reducer: NewRecordFeature.init
    )

    await store.send(\.view.finalizeReport)
  }
}
