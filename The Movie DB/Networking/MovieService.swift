//
//  MovieService.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

protocol MovieServiceProtocol {
    func fetchNowPlayingMovies(page: Int) async throws -> [Movie]
    func searchMovies(query: String, page: Int) async throws -> [Movie]
}

class MovieService: MovieServiceProtocol {
    
    private let apiClient: APIClientProtocol
    
    init (apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchNowPlayingMovies(page: Int = 1) async throws -> [Movie] {
        let endpoint = APIEndpoint(path: "/movie/now_playing", parameters: ["page": "\(page)"])
        return try await apiClient.fetch(endpoint, responseType: MovieResponse.self).results
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> [Movie] {
        let endpoint = APIEndpoint(path: "/search/movie", parameters: ["query": query, "page": "\(page)"])
        return try await apiClient.fetch(endpoint, responseType: MovieResponse.self).results
    }
}
