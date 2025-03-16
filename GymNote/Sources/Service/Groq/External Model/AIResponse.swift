//
//  AIResponse.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

struct AIResponse: Codable, Equatable {
  let choices: [Choice]
}

struct Choice: Codable, Equatable {
  let message: Message
}

struct Message: Codable, Equatable {
  let content: String
  let role: MessageRole
}

enum MessageRole: String, Codable, Equatable {
  case assistant
  case user
  case unknown

  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self = MessageRole(rawValue: string) ?? .unknown
  }
}
