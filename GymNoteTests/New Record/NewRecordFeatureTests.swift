//
//  NewRecordFeatureTests.swift
//  GymNote
//
//  Created by Lubos Lehota on 30/12/2024.
//

import ComposableArchitecture
import Testing
@testable import GymNote

struct NewRecordFeatureTests {

  @Test
  func finalizeReportIfCompleteAndDismiss() async throws {
    let mock = ExtractedReport(date: .now, exercise: "bench-press", repetitions: 5, weight: 100, weightUnit: .kilograms)
    let testExpectation = TestExpectation()

    let store = await TestStore(
      initialState: NewRecordFeature.State(extractedReport: mock),
      reducer: NewRecordFeature.init,
      withDependencies: {
        $0.dismiss = .init {
          testExpectation.fulfill()
        }
      }
    )

    await store.send(\.view.finalizeReport) { state in
      state.finalizedReport = try NewRecord(
        date: mock.date,
        exercise: .unknown(mock.exercise.unwrap()),
        repetitions: mock.repetitions.unwrap(),
        weight: .init(value: mock.weight.unwrap(), unit: mock.weightUnit.unwrap())
      )
    }

    let wasFullfilled = try await testExpectation.checkIfFulfilled()
    #expect(wasFullfilled)
  }

  @Test
  func dontFinalizeReportIfIncomplete() async throws {
    let mock = ExtractedReport(date: .now, exercise: "bench-press", weight: 100, weightUnit: .kilograms)

    let store = await TestStore(
      initialState: NewRecordFeature.State(extractedReport: mock),
      reducer: NewRecordFeature.init
    )

    await store.send(\.view.finalizeReport)
  }

  @Test
  func dontFinalizeReportIfInvalidData() async throws {
    let mock = ExtractedReport(date: .now, exercise: "bench-press", repetitions: 5, weight: 100, weightUnit: .carats)

    let store = await TestStore(
      initialState: NewRecordFeature.State(extractedReport: mock),
      reducer: NewRecordFeature.init
    )

    await store.send(\.view.finalizeReport)
  }
}
