//
//  AIResponse.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

public struct AIResponse: Codable, Equatable {
  public let choices: [Choice]
}

public struct Choice: Codable, Equatable {
  public let message: Message
}

public struct Message: Codable, Equatable {
  public let content: String
  public let role: MessageRole
}

public enum MessageRole: String, Codable, Equatable {
  case assistant
  case user
  case unknown

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self = MessageRole(rawValue: string) ?? .unknown
  }
}
