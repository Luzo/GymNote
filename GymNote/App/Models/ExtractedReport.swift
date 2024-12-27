//
//  ExtractedReport.swift
//  GymNote
//
//  Created by Lubos Lehota on 27/12/2024.
//

// TODO: Create domain model
struct ExtractedReport: Codable {
  let date: String?
  let exercise: String?
  let repetitions: Int?
  let weight: Int?
  let weightUnit: String?
}
