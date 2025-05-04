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

public struct ExerciseRecordContainerService {
  public var save: (ExerciseRecord) async throws -> Void
  public var fetchAll: () async throws -> [ExerciseRecord]
  public var delete: (ExerciseRecord.ID) async throws -> Void
}

extension ExerciseRecordContainerService: DependencyKey {
  public static var liveValue: ExerciseRecordContainerService {
    @Dependency(\.modelContainer) var modelContainer

    return .init(
      save: { record in
        try await MainActor.run {
          let context = modelContainer.mainContext
          context.insert(record)
          try context.save()
        }
      },
      fetchAll: {
        try await MainActor.run {
          let context = modelContainer.mainContext
          return try context.fetch(FetchDescriptor<ExerciseRecord>())
        }
      },
      delete: { recordID in
        try await MainActor.run {
          let context = modelContainer.mainContext
          let descriptor = FetchDescriptor<ExerciseRecord>(predicate: #Predicate { $0.id == recordID })
          let records = try context.fetch(descriptor)
          for record in records {
            context.delete(record)
          }
          try context.save()
        }
      }
    )
  }
}
