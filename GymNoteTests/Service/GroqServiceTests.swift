//
//  GroqServiceTests.swift
//  GymNote
//
//  Created by Lubos Lehota on 16/03/2025.
//

import CustomDump
import ComposableArchitecture
import Foundation
import Testing
@testable import GymNote

private struct GroqServiceTests {

  @Test(.serialized, arguments: LoadResultsFromGroqServiceParameters.prepareParameters())
  func loadResultsFromGroqService(
    parameters: LoadResultsFromGroqServiceParameters
  ) async throws {
    let mockedNetwork = NetworkServiceMock()
    mockedNetwork.mockResponse = parameters.extractedReportResult.map { $0 as Any }

    let result = await withDependencies  { dependencies in
      dependencies.networkService = mockedNetwork
      dependencies.date = .constant(parameters.today)
    } operation: {
      let sut = GroqService.liveValue
      return await sut.extractReport("")
    }

    expectNoDifference(result, parameters.expectedResponse)
  }
}

private extension GroqServiceTests {
  static func jsonString(from object: Codable) -> String? {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted

      do {
          let jsonData = try encoder.encode(object)
          if let jsonString = String(data: jsonData, encoding: .utf8) {
              return jsonString
          }
      } catch {
          print("Error encoding object to JSON: \(error)")
      }

      return nil
  }

  struct LoadResultsFromGroqServiceParameters {
    let id: Int
    let today: Date
    let extractedReportResult: Result<AIResponse, NetworkError>
    let expectedResponse: Result<ExtractedReport, AIResponseError>

    static func prepareParameters() -> [LoadResultsFromGroqServiceParameters] {
      return [
        withDate(id: 0, date: nil),
        withDate(id: 1, date: Date.init(timeIntervalSince1970: 0)),
        LoadResultsFromGroqServiceParameters(
          id: 2,
          today: .now,
          extractedReportResult: .success(AIResponse(choices: [])),
          expectedResponse: .failure(.networkError(.noData))
        ),
        LoadResultsFromGroqServiceParameters(
          id: 3,
          today: .now,
          extractedReportResult: .success(AIResponse(choices: [
            .init(message: .init(content: "[]", role: .assistant))
          ])),
          expectedResponse: .failure(.networkError(.decodingError))
        ),
        LoadResultsFromGroqServiceParameters(
          id: 4,
          today: .now,
          extractedReportResult: .failure(.invalidURL),
          expectedResponse: .failure(.networkError(.invalidURL))
        )
      ]
    }

    private static func withDate(id: Int, date: Date?) -> LoadResultsFromGroqServiceParameters {
      let today = Date.now
      let reportExternal = ExtractedReportExternal(date: date?.ISO8601Format(), exercise: nil, repetitions: nil, weight: nil, weightUnit: nil)
      let report = ExtractedReport(date: date ?? today, exercise: nil, repetitions: nil, weight: nil, weightUnit: nil)
      let aiResponse = AIResponse(
        choices: [
          .init(message: .init(content: jsonString(from: reportExternal) ?? "", role: .assistant))
        ]
      )

      return LoadResultsFromGroqServiceParameters(
        id: id,
        today: today,
        extractedReportResult: .success(aiResponse),
        expectedResponse: .success(report)
      )
    }
  }
}

private final class NetworkServiceMock: NetworkServiceProvider {
  var mockResponse: Result<Any, NetworkError> = .failure(.noData)

  func request<T: Decodable>(
    endpoint: String,
    method: RequestMethod,
    parameters: [String: Any],
    headers: [String: String]
  ) async -> Result<T, NetworkError> {
    switch mockResponse {
    case .success(let data):
      if let data = data as? T {
        return .success(data)
      } else {
        fatalError("Response type mismatch, expected \(T.self), got \(type(of: data))")
      }
    case .failure(let error):
      return .failure(error)
    }
  }
}
