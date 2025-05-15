//
//  NetworkService.swift
//  GymNote
//
//  Created by Lubos Lehota on 16/03/2025.
//

import Dependencies
import Foundation
import Service

extension NetworkServiceKey: @retroactive DependencyKey {
  public static var liveValue: NetworkServiceProvider {
    NetworkService()
  }
}

final class NetworkService: NetworkServiceProvider {
  func request<T: Decodable>(
    endpoint: String,
    method: RequestMethod,
    parameters: [String: Any],
    headers: [String: String],
    session: URLSession
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
    } catch is DecodingError {
      return .failure(.decodingError)
    } catch {
      return .failure(.unknown)
    }
  }
}
