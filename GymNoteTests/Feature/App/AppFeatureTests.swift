//
//  GroqServiceTests.swift
//  GymNote
//
//  Created by Lubos Lehota on 30/12/2024.
//

import ComposableArchitecture
import Testing
@testable import GymNote

struct AppFeatureTests {

  @Test
  func tryExtractReportOnExtractReportTapped() async throws {
    let store = await TestStore(
      initialState: AppFeature.State(),
      reducer: AppFeature.init,
      withDependencies: {
        $0.groqService.extractReport = { _ in
            .failure(.networkError(.noData))
        }
      }
    )

    await store.send(\.view.extractReport)
    await store.receive(\.receivedAIResponse.failure)
  }

  @Test
  func extractReportOnExtractReportTappedAndNavigateToNewReport() async throws {
    let mock = ExtractedReport(date: .now)
    let store = await TestStore(
      initialState: AppFeature.State(),
      reducer: AppFeature.init,
      withDependencies: {
        $0.groqService.extractReport = { _ in
          .success(mock)
        }
      }
    )

    await store.send(\.view.extractReport)
    await store.receive(\.receivedAIResponse.success) { state in
      state.newRecordState = .init(extractedReport: mock)
    }
  }
}
