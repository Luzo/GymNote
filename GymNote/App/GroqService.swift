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
        let decoder = JSONDecoder()

        guard
          let parameters = ExtractReport.prepareParameters(text: text).value,
          let inputJsonData = try? JSONSerialization.data(withJSONObject: parameters),
          let request = ExtractReport.prepareURLRequest(inputJsonData: inputJsonData).value,
          let (data, _) = try? await URLSession.shared.data(for: request),
          let aiResponse = try? decoder.decode(AIResponse.self, from: data)
        else {
          return .failure(AIResponseError.serializationError)
        }

        let message = aiResponse.choices.compactMap(\.message).first(where: { $0.role == .assistant })

        guard
          let content = message?.content.data(using: .utf8)
        else {
          return .failure(AIResponseError.noResponse)
        }

        do {
          let extractedData = try decoder.decode(ExtractedReport.self, from: content)
          return .success(extractedData)
        } catch {
          return .failure(.noResponse)
        }
      }
    )
  }

  static var previewValue: GroqService {
    .init(extractReport: { _ in .failure(.noResponse) })
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
    Transform date in response to ISO 8601, unit in standard abbreviation:
    
    {
    "date": String?,
    "exercise": String?,
    "repetitions": Int?,
    "weight": Int?,
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

  static func prepareURLRequest(inputJsonData: Data) -> Result<URLRequest, AIResponseError> {
    let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "apiKeyGroq") as? String else {
      return .failure(.missingApiKey)
    }

    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = inputJsonData

    return .success(request)
  }
}
