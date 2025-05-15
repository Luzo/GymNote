//
//  ModelContainer.swift
//  GymNote
//
//  Created by Lubos Lehota on 31/12/2024.
//

import Dependencies
import Exercise
import Foundation
import Service
import SwiftData

extension ModelContainerKey: @retroactive DependencyKey {
  public static var liveValue: ModelContainer {
    ModelContainer.createModelContainer(withName: "default.store")
  }
}

extension ModelContainer{
  fileprivate static func createModelContainer(withName name: String) -> ModelContainer {
    let databasePath = URL.applicationSupportDirectory.appending(path: name)
    let config = ModelConfiguration(url: databasePath)
    do {
      return try ModelContainer(for: ExerciseRecord.self, configurations: config)
    } catch {
      fatalError("Could not create database")
    }
  }
}
