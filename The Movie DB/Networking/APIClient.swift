//
//  APIClient.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

final class APIClient {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "4f57007d7fd386a068d851597acfb9df"
    
    func fetch<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        // Validate URL
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add API key to query parameters
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var queryItems = urlComponents.queryItems ?? []
            queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
            if let parameters = endpoint.parameters {
                parameters.forEach { key, value in
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            urlComponents.queryItems = queryItems
            request.url = urlComponents.url
        }
        
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            // Parse successful response
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError
            }
            
        case 400...499:
            // Parse client-side errors
            if let tmdbError = try? JSONDecoder().decode(TMDbErrorResponse.self, from: data) {
                throw APIError.tmdbError(code: tmdbError.statusCode, message: tmdbError.statusMessage)
            } else {
                throw APIError.clientError(statusCode: httpResponse.statusCode)
            }
            
        case 500...599:
            // Parse server-side errors
            throw APIError.serverError(statusCode: httpResponse.statusCode)
            
        default:
            throw APIError.invalidResponse
        }
    }
}
