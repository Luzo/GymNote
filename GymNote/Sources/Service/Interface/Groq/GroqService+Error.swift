//
//  GroqService+Error.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

public enum AIResponseError: Error, Equatable {
  case missingApiKey
  case networkError(NetworkError)
}
