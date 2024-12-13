//
//  Mocks.swift
//  The Movie DBTests
//
//  Created by Patryk Drozd on 13/12/2024.
//

import UIKit
@testable import The_Movie_DB

// MARK: - Mock Movie Service

final class MockMovieService: MovieServiceProtocol {
    var mockResult: Result<MovieResponse, APIError>?

    func fetchNowPlayingMovies(page: Int) async throws -> MovieResponse {
        switch mockResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        case .none:
            throw APIError.custom(message: "unknown")
        }
    }

    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        throw APIError.custom(message: "unknown")
    }
}

// MARK: - Mock Image Service

final class MockImageService: ImageServiceProtocol {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
}

// MARK: - Mock MoviesViewModelDelegate

final class MockMoviesViewModelDelegate: MoviesViewModelDelegate {
    var updatedCellModels: [MovieCellViewModel]?
    var encounteredError: String?
    var isLoadingState: Bool?

    func moviesViewModel(_ viewModel: MoviesViewModel, didUpdateMovies movieCellModels: [MovieCellViewModel]) {
        self.updatedCellModels = movieCellModels
    }

    func moviesViewModel(_ viewModel: MoviesViewModel, didEncounterError error: String) {
        encounteredError = error
    }

    func moviesViewModel(_ viewModel: MoviesViewModel, didChangeLoadingState isLoading: Bool) {
        isLoadingState = isLoading
    }
}

// MARK: - Mock Favorites Manager

final class MockFavoritesManager: FavoritesManagerProtocol {
    private var favorites: Set<Int> = []

    func isFavorite(movieID: Int) -> Bool {
        return favorites.contains(movieID)
    }

    func toggleFavorite(movieID: Int) {
        if favorites.contains(movieID) {
            favorites.remove(movieID)
        } else {
            favorites.insert(movieID)
        }
        NotificationCenter.default.post(
            name: .favoriteStatusChanged,
            object: nil,
            userInfo: ["movieID": movieID]
        )
    }
}
