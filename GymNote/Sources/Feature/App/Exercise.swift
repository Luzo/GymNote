//
//  Exercise.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

enum ExerciseGroup: String, Equatable, CaseIterable {
  case chest
  case biceps
  case triceps
  case back
  case shoulders
  case legs
}

enum Exercise: Equatable {
  case chest(Chest)
  case biceps(Biceps)
  case triceps(Triceps)
  case back(Back)
  case shoulders(Shoulders)
  case legs(Legs)
}

extension Exercise: Codable {
  init?(rawValue: String) {
    guard
      let prefix = rawValue.split(separator: "-").first,
      let group = ExerciseGroup.init(rawValue: String(prefix)),
      let value = Exercise(forGroup: group, exerciseName: rawValue)
    else {
      return nil
    }

    self = value
  }
}

extension Exercise: RawRepresentable {
  var rawValue: String {
    switch self {
    case let .chest(exercise):
      return exercise.rawValue
    case let .biceps(exercise):
      return exercise.rawValue
    case let .triceps(exercise):
      return exercise.rawValue
    case let .back(exercise):
      return exercise.rawValue
    case let .shoulders(exercise):
      return exercise.rawValue
    case let .legs(exercise):
      return exercise.rawValue
    }
  }
}

extension Exercise {
  static var allCases: [Exercise] {
    ExerciseGroup.allCases.flatMap { group in
      switch group {
      case .chest: return Chest.allCases.map { Exercise.chest($0) }
      case .biceps: return Biceps.allCases.map { .biceps($0) }
      case .triceps: return Triceps.allCases.map { .triceps($0) }
      case .back: return Back.allCases.map { .back($0) }
      case .shoulders: return Shoulders.allCases.map { .shoulders($0) }
      case .legs: return Legs.allCases.map { .legs($0) }
      }
    }
  }

  var group: ExerciseGroup {
    switch self {
    case .chest:
      return .chest
    case .biceps:
      return .biceps
    case .triceps:
      return .triceps
    case .back:
      return .back
    case .shoulders:
      return .shoulders
    case .legs:
      return .legs
    }
  }
}

private extension Exercise {
  init?(forGroup group: ExerciseGroup, exerciseName: String) {
    var value: Exercise?

    switch group {
    case .chest:
      value = Exercise.Chest(rawValue: exerciseName).map { Exercise.chest($0) }
    case .biceps:
      value = Exercise.Biceps(rawValue: exerciseName).map { .biceps($0) }
    case .triceps:
      value = Exercise.Triceps(rawValue: exerciseName).map { .triceps($0) }
    case .back:
      value = Exercise.Back(rawValue: exerciseName).map { .back($0) }
    case .shoulders:
      value = Exercise.Shoulders(rawValue: exerciseName).map { .shoulders($0) }
    case .legs:
      value = Exercise.Legs(rawValue: exerciseName).map { .legs($0) }
    }

    guard let value else { return nil }
    self = value
  }
}
