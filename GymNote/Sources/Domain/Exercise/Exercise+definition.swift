//
//  Exercise+definition.swift
//  GymNote
//
//  Created by Lubos Lehota on 08/02/2025.
//

public extension Exercise {
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

public extension Exercise {
  enum Biceps: String, Equatable, Codable, CaseIterable {
    case hammerCurl = "biceps-hammerCurl"
    case preacherCurl = "biceps-preacherCurl"
    case ezBarCurl = "biceps-ezBarCurl"
    case cableBicepsCurl = "biceps-cableBicepsCurl"
    case chinup = "biceps-chinup"
  }
}

public extension Exercise {
  enum Triceps: String, Equatable, Codable, CaseIterable {
    case dips = "triceps-dips"
    case machineDips = "triceps-machineDips"
    case cablePushdown = "triceps-cablePushdown"
    case kickback = "triceps-kickback"
    case skullCrushers = "triceps-skullCrushers"
  }
}

public extension Exercise {
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

public extension Exercise {
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

public extension Exercise {
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

