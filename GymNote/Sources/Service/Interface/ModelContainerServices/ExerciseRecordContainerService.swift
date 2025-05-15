//
//  ExerciseRecordContainerService.swift
//  GymNote
//
//  Created by Lubos Lehota on 16/03/2025.
//

import Dependencies
import Exercise
import Foundation
import SwiftData

// TODO: Fix error types
extension DependencyValues {
  public var exerciseRecordContainerService: ExerciseRecordContainerService {
    get { self[ExerciseRecordContainerService.self] }
    set { self[ExerciseRecordContainerService.self] = newValue }
  }
}

extension ExerciseRecordContainerService: TestDependencyKey {
  public static var testValue: ExerciseRecordContainerService {
    // TODO: make a proper testing value
    .init(
      save: { _ in },
      fetchAll: { [] },
      delete: { _ in }
    )
  }
}

public struct ExerciseRecordContainerService {
  public var save: (ExerciseRecord) async throws -> Void
  public var fetchAll: () async throws -> [ExerciseRecord]
  public var delete: (ExerciseRecord.ID) async throws -> Void

  public init(save: @escaping (ExerciseRecord) async throws -> Void, fetchAll: @escaping () async throws -> [ExerciseRecord], delete: @escaping (ExerciseRecord.ID) async throws -> Void) {
    self.save = save
    self.fetchAll = fetchAll
    self.delete = delete
  }
}
