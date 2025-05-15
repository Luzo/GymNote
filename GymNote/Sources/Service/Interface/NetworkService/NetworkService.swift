//
//  NetworkService.swift
//  GymNote
//
//  Created by Lubos Lehota on 16/03/2025.
//

import Dependencies
import Foundation

// MARK: - NetworkError
public enum NetworkError: Error, Equatable {
  case invalidURL
  case noData
  case decodingError
  case serverError(Int)
  case unknown
}


public enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}


extension DependencyValues {
  public var networkService: NetworkServiceProvider {
    get { self[NetworkServiceKey.self] }
    set { self[NetworkServiceKey.self] = newValue }
  }
}

public enum NetworkServiceKey {}

extension NetworkServiceKey: TestDependencyKey {
  public static var testValue: NetworkServiceProvider {
    NetworkServiceProviderMock()
  }

  struct NetworkServiceProviderMock: NetworkServiceProvider {
    func request<T>(
      endpoint: String,
      method: RequestMethod,
      parameters: [String : Any],
      headers: [String : String],
      session: URLSession
    ) async -> Result<T, NetworkError> where T : Decodable {
      .failure(.noData)
    }
  }
}

public protocol NetworkServiceProvider {
  func request<T: Decodable>(
    endpoint: String,
    method: RequestMethod,
    parameters: [String: Any],
    headers: [String: String],
    session: URLSession
  ) async -> Result<T, NetworkError>
}
