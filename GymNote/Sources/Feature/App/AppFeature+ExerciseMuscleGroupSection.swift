//
//  AppView+ExerciseMuscleGroupSection.swift
//  GymNote
//
//  Created by Lubos Lehota on 08/02/2025.
//

import Exercise

struct ExerciseMuscleGroupSection: Equatable, Hashable {
  var name: String
  var sections: [ExerciseSection]
}

struct ExerciseSection: Equatable, Hashable {
  var name: String
  var records: [ExerciseRecord]
}
