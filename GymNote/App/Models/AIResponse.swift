//
//  AIResponse.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

enum AIResponseError: Error {
  case missingApiKey
  case serializationError
  case noResponse
}

struct AIResponse: Codable {
  let choices: [Choice]
}

struct Choice: Codable {
  let message: Message
}

struct Message: Codable {
  let content: String
  let role: MessageRole
}

enum MessageRole: String, Codable {
  case assistant
  case user
  case unknown

  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self = MessageRole(rawValue: string) ?? .unknown
  }
}
