//
//  GroqService+Error.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

enum AIResponseError: Error, Equatable {
  case missingApiKey
  case networkError(NetworkError)
}
