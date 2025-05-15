//
//  ExerciseRecordContainerService.swift
//  GymNote
//
//  Created by Lubos Lehota on 16/03/2025.
//

import Dependencies
import Exercise
import Foundation
import Service
import SwiftData

extension ExerciseRecordContainerService: @retroactive DependencyKey {
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
