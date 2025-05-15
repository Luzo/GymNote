//
//  GroqService.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

import Dependencies
import Exercise
import Foundation

public struct GroqService {
  public var extractReport: (String) async -> Result<ExtractedReport, AIResponseError>

  public init(extractReport: @escaping (String) async -> Result<ExtractedReport, AIResponseError>) {
    self.extractReport = extractReport
  }
}

extension GroqService: TestDependencyKey {
  public static var testValue: GroqService {
    .init(extractReport: { _ in .failure(.missingApiKey) } )
  }

}

extension DependencyValues {
  public var groqService: GroqService {
    get { self[GroqService.self] }
    set { self[GroqService.self] = newValue }
  }
}

