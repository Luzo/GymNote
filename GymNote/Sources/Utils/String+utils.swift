//
//  String+utils.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

extension String {
  var nilIfEmpty: String? {
    isEmpty ? nil : self
  }
}
