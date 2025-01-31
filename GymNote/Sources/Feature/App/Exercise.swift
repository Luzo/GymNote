//
//  Exercise.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

// TODO: remove string and localize
enum ExerciseGroup: String, Equatable, CaseIterable {
  case chest
  case biceps
  case triceps
  case back
  case shoulders
  case legs
}

enum Exercise: Equatable, Codable, RawRepresentable {
  case chest(Chest)
  case biceps(Biceps)
  case triceps(Triceps)
  case back(Back)
  case shoulders(Shoulders)
  case legs(Legs)

  static var allCases: [Exercise] {
    Chest.allCases.map { Exercise.chest($0) } +
    Biceps.allCases.map { Exercise.biceps($0) } +
    Triceps.allCases.map { Exercise.triceps($0) } +
    Back.allCases.map { Exercise.back($0) } +
    Shoulders.allCases.map { Exercise.shoulders($0) } +
    Legs.allCases.map { Exercise.legs($0) }
  }

  init?(rawValue: String) {
    var value: Exercise?

    switch rawValue {
    case let rawValue where rawValue.hasPrefix("chest"):
      if let chestExercise = Exercise.Chest(rawValue: rawValue) {
        value = .chest(chestExercise)
      }
    case let rawValue where rawValue.hasPrefix("biceps"):
      if let bicepsExercise = Exercise.Biceps(rawValue: rawValue) {
        value = .biceps(bicepsExercise)
      }
    case let rawValue where rawValue.hasPrefix("triceps"):
      if let tricepsExercise = Exercise.Triceps(rawValue: rawValue) {
        value = .triceps(tricepsExercise)
      }
    case let rawValue where rawValue.hasPrefix("back"):
      if let backExercise = Exercise.Back(rawValue: rawValue) {
        value = .back(backExercise)
      }
    case let rawValue where rawValue.hasPrefix("shoulders"):
      if let shouldersExercise = Exercise.Shoulders(rawValue: rawValue) {
        value = .shoulders(shouldersExercise)
      }
    case let rawValue where rawValue.hasPrefix("legs"):
      if let legsExercise = Exercise.Legs(rawValue: rawValue) {
        value = .legs(legsExercise)
      }
    default:
      return nil
    }

    guard let value else { return nil }
    self = value
  }

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

extension Exercise {
  enum Chest: String, Equatable, Codable, CaseIterable {
    case pushup = "chest-pushup"
    case benchPress = "chest-benchPress"
    case inclineBenchPress = "chest-inclineBenchPress"
    case declineBenchPress = "chest-declineBenchPress"
    case dumbellBenchPress = "chest-dumbellBenchPress"
    case inclineDumbellBenchPress = "chest-inclineDumbellBenchPress"
    case declineDumbellBenchPress = "chest-declineDumbellBenchPress"
    case machineFlyes = "chest-machineFlyes"
    case dumbellFlyes = "chest-dumbellFlyes"
    case cableCrossover = "chest-cableCrossover"
    case pullover = "chest-pullover"
  }
}

extension Exercise {
  enum Biceps: String, Equatable, Codable, CaseIterable {
    case hammerCurl = "biceps-hammerCurl"
    case preacherCurl = "biceps-preacherCurl"
    case ezBarCurl = "biceps-ezBarCurl"
    case cableBicepsCurl = "biceps-cableBicepsCurl"
    case chinup = "biceps-chinup"
  }
}

extension Exercise {
  enum Triceps: String, Equatable, Codable, CaseIterable {
    case dips = "triceps-dips"
    case machineDips = "triceps-machineDips"
    case cablePushdown = "triceps-cablePushdown"
    case kickback = "triceps-kickback"
    case skullCrushers = "triceps-skullCrushers"
  }
}

extension Exercise {
  enum Back: String, Equatable, Codable, CaseIterable {
    case pullup = "back-pullup"
    case cableRow = "back-cableRow"
    case bentOverRow = "back-bentOverRow"
    case dumbellRow = "back-dumbellRow"
    case latPulldown = "back-latPulldown"
    case deadlift = "back-deadlift"
    case dumbellShrugs = "back-dumbellShrugs"
  }
}

extension Exercise {
  enum Shoulders: String, Equatable, Codable, CaseIterable {
    case shoulderPress = "shoulders-shoulderPress"
    case overheadPress = "shoulders-overheadPress"
    case frontRaise = "shoulders-frontRaise"
    case reverseFly = "shoulders-reverseFly"
    case facePull = "shoulders-facePull"
    case backPulls = "shoulders-backPulls"
    case arnoldPress = "shoulders-arnoldPress"
    case uprightRow = "shoulders-uprightRow"
    case lateralRaise = "shoulders-lateralRaise"
    case cableLateralRaise = "shoulders-cableLateralRaise"
  }
}

extension Exercise {
  enum Legs: String, Equatable, Codable, CaseIterable {
    case legPress = "legs-legPress"
    case squats = "legs-squats"
    case bulgarianSquat = "legs-bulgarianSquat"
    case hackSquat = "legs-hackSquat"
    case machineSquat = "legs-machineSquat"
    case lunge = "legs-lunge"
    case legExtensions = "legs-legExtensions"
    case legCurls = "legs-legCurls"
    case hipThrusts = "legs-hipThrusts"
    case kickback = "legs-kickback"
    case romanianDeadlift = "legs-romanianDeadlift"
    case calfRaise = "legs-calfRaise"
    case seatedCalfRaise = "legs-seatedCalfRaise"
  }
}

