//
//  NetworkService.swift
//  GymNote
//
//  Created by Lubos Lehota on 16/03/2025.
//

import Dependencies
import Foundation

// MARK: - NetworkError
enum NetworkError: Error, Equatable {
  case invalidURL
  case noData
  case decodingError
  case serverError(Int)
  case unknown
}


enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}


extension DependencyValues {
  var networkService: NetworkServiceProvider {
    get { self[NetworkServiceKey.self] }
    set { self[NetworkServiceKey.self] = newValue }
  }
}

enum NetworkServiceKey: DependencyKey {
  public static var liveValue: NetworkServiceProvider {
    NetworkService()
  }
}

protocol NetworkServiceProvider {
  func request<T: Decodable>(
    endpoint: String,
    method: RequestMethod,
    parameters: [String: Any],
    headers: [String: String]
  ) async -> Result<T, NetworkError>
}

final class NetworkService: NetworkServiceProvider {
  private let session: URLSession

  fileprivate init(session: URLSession = .shared) {
    self.session = session
  }

  func request<T: Decodable>(
    endpoint: String,
    method: RequestMethod,
    parameters: [String: Any],
    headers: [String: String]
  ) async -> Result<T, NetworkError> {
    guard let url = URL(string: endpoint) else {
      return .failure(.invalidURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

    if !parameters.isEmpty {
      request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    do {
      let (data, response) = try await session.data(for: request)

      if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
        return .failure(.serverError(httpResponse.statusCode))
      }

      let decodedResponse = try JSONDecoder().decode(T.self, from: data)
      return .success(decodedResponse)
    } catch let decodingError as DecodingError {
      return .failure(.decodingError)
    } catch {
      return .failure(.unknown)
    }
  }
}
