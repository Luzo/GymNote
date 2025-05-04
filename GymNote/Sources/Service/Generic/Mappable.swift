//
//  Mappable.swift
//  GymNote
//
//  Created by Lubos Lehota on 29/12/2024.
//

protocol DomainMappable {
  associatedtype DomainModel: Equatable

  func toDomainModel() -> DomainModel
}
