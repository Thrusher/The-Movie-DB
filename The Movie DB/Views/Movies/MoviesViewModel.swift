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
    
    var onMoviesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(movieService: MovieServiceProtocol, imageService: ImageServiceProtocol) {
        self.movieService = movieService
        self.imageService = imageService
    }

    func fetchMovies(reset: Bool = false) {
        guard !isLoading else { return }

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
                onError?(error.errorDescription ?? "An unexpected error occurred.")
            } catch {
                isLoading = false
                onError?("An unexpected error occurred: \(error.localizedDescription)")
            }
        }
    }

    func refreshMovies() {
        fetchMovies(reset: true)
    }
}
