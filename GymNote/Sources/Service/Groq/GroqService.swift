//
//  GroqService.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

import Dependencies
import Foundation

struct GroqService {
  var extractReport: (String) async -> Result<ExtractedReport, AIResponseError>
}

private extension GroqService {
  enum ExtractReport {}
}

extension DependencyValues {
  var groqService: GroqService {
    get { self[GroqService.self] }
    set { self[GroqService.self] = newValue }
  }
}

extension GroqService: DependencyKey {
  static var liveValue: GroqService {
    .init(
      extractReport: { text in
        @Dependency(\.networkService) var networkService

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "apiKeyGroq") as? String else {
          return .failure(.missingApiKey)
        }

        let result: Result<AIResponse, NetworkError> = await networkService.request(
          endpoint: "https://api.groq.com/openai/v1/chat/completions",
          method: .post,
          parameters: (try? ExtractReport.prepareParameters(text: text).get()) ?? [:],
          headers: ["Authorization": "Bearer \(apiKey)"]
        )

        return result
          .mapError(AIResponseError.networkError)
          .flatMap(ExtractReport.decodeAIResponse)
      }
    )
  }

  static var previewValue: GroqService {
    .init(extractReport: { _ in .failure(.networkError(.noData)) })
  }

  static var testValue: GroqService {
    .init(extractReport: { _ in fatalError("extractReport not mocked") })
  }
}

private extension GroqService.ExtractReport {
  static func prepareParameters(text: String) -> Result<[String: Any], AIResponseError> {
    @Dependency(\.date.now) var today
    let prompt = """
    Today's Date: \(today)
    Extract JSON data, without any other text in response, format json without any newlines. If day of the week is supplied, find the closest day of the week that passed.
    Transform date in response to ISO 8601, unit in standard abbreviation.
    \(prepareKnownExercisesPrompt()):
    
    {
    "date": String?,
    "exercise": Exercise?,
    "repetitions": Int?,
    "weight": Double?,
    "weightUnit": String?
    }
    
    from: "\(text)"
    """

    let parameters: [String: Any] = [
      "messages": [
        [
          "role": "user",
          "content": prompt,
        ]
      ],
      "model": "llama3-70b-8192",
      "temperature": 1,
      "max_tokens": 1024,
      "top_p": 1,
      "stream": false
    ]

    return .success(parameters)
  }

  static func prepareKnownExercisesPrompt() -> String {
    return """
    The enum Exercise is defined as following, please replace extracted exercise with one of the folowing options,
    if it matches or resembels something from Exercise enum. 
    If not found, return it as unknown-string.
    E.g. if received push ups - return chest-pushup and so on: 
    
    \(Exercise.allCases.map(\.rawValue))
    """
  }

  static func decodeAIResponse(_ aiResponse: AIResponse) -> Result<ExtractedReport, AIResponseError> {
    let message = aiResponse.choices.compactMap(\.message).first(where: { $0.role == .assistant })

    guard let content = message?.content.data(using: .utf8) else {
      return .failure(.networkError(.noData))
    }

    do {
      let extractedData = try JSONDecoder().decode(ExtractedReportExternal.self, from: content)
      return .success(extractedData.toDomainModel())
    } catch {
      return .failure(.networkError(.decodingError))
    }
  }
}
