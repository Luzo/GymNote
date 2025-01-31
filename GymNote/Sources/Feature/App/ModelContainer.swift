//
//  ModelContainer.swift
//  GymNote
//
//  Created by Lubos Lehota on 31/12/2024.
//

import Dependencies
import SwiftData
import Foundation

extension DependencyValues {
  var modelContainer: ModelContainer {
    get { self[ModelContainer.self] }
    set { self[ModelContainer.self] = newValue }
  }
}

extension ModelContainer: @retroactive DependencyKey {
  public static var liveValue: ModelContainer {
    createModelContainer(withName: "default.store")
  }

  public static var testValue: ModelContainer {
    createModelContainer(withName: "default.preview.store")
  }

  public static var previewValue: ModelContainer {
    createModelContainer(withName: "default.test.store")
  }

  public static func createModelContainer(withName name: String) -> ModelContainer {
    let databasePath = URL.applicationSupportDirectory.appending(path: name)
    let config = ModelConfiguration(url: databasePath)
    do {
      return try ModelContainer(for: ExerciseRecord.self, configurations: config)
    } catch {
      fatalError("Could not create database")
    }
  }
}
