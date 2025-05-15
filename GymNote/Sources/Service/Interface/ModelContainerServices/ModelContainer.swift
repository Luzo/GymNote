//
//  ModelContainer.swift
//  GymNote
//
//  Created by Lubos Lehota on 31/12/2024.
//

import Dependencies
import Foundation
import SwiftData

public enum ModelContainerKey {}

extension ModelContainerKey: TestDependencyKey {
  public static var testValue: ModelContainer {
    fatalError()
  }
}

extension DependencyValues {
  public var modelContainer: ModelContainer {
    get { self[ModelContainerKey.self] }
    set { self[ModelContainerKey.self] = newValue }
  }
}
