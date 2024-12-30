//
//  NewRecord.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

import Foundation

struct NewRecord: Equatable {
  let date: Date
  let exercise: Exercise
  let repetitions: Int
  let weight: Measurement<UnitMass>
}
