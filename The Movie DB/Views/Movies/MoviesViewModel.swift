//
//  MoviesViewModel.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

class MoviesViewModel {
    let movieService: MovieServiceProtocol
    let imageService: ImageServiceProtocol
    
    private var currentPage = 1
    private var isLoading = false

    var movies: [Movie] = [] {
        didSet {
            onMoviesUpdated?()
        }
    }

    // Callbacks to update the UI
    var onMoviesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(movieService: MovieServiceProtocol, imageService: ImageServiceProtocol) {
        self.movieService = movieService
        self.imageService = imageService
    }

    /// Fetch popular movies (default list)
    func fetchMovies(reset: Bool = false) {
        guard !isLoading else { return } // Prevent duplicate requests

        if reset {
            currentPage = 1
            movies = []
        }

        isLoading = true
        Task {
            do {
                let newMovies = try await movieService.fetchNowPlayingMovies(page: currentPage)
                currentPage += 1
                movies.append(contentsOf: newMovies)
                isLoading = false
            } catch let error as APIError {
                isLoading = false
                onError?(error.localizedDescription)
            } catch {
                isLoading = false
                onError?("An unexpected error occurred: \(error.localizedDescription)")
            }
        }
    }

    /// Refresh the movie list
    func refreshMovies() {
        fetchMovies(reset: true)
    }
}
