//
//  File.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case tmdbError(code: Int, message: String)
    case serverError(statusCode: Int)
    case clientError(statusCode: Int)
    case custom(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError:
            return "Failed to decode the data."
        case .tmdbError(let code, let message):
            return "TMDb Error \(code): \(message)"
        case .serverError(let statusCode):
            return "Server Error: HTTP \(statusCode)."
        case .clientError(let statusCode):
            return "Client Error: HTTP \(statusCode)."
        case .custom(let message):
            return message
        }
    }
}
