//
//  MoviesViewModel.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

final class MoviesViewModel {
    let movieService: MovieServiceProtocol
    let imageService: ImageServiceProtocol
    
    private var currentPage = 1
    private var totalPages = 1

    private var isLoading = false {
        didSet {
            onLoadingStateChange?(isLoading)
        }
    }

    var movies: [Movie] = [] {
        didSet {
            onMoviesUpdated?()
        }
    }
    
    var onMoviesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    
    init(movieService: MovieServiceProtocol, imageService: ImageServiceProtocol) {
        self.movieService = movieService
        self.imageService = imageService
    }

    func fetchMovies(reset: Bool = false) {
        guard !isLoading else { return }
        guard reset || currentPage <= totalPages else { return }

        if reset {
            currentPage = 1
            movies = []
        }

        isLoading = true
        Task {
            do {
                let movieResponse = try await movieService.fetchNowPlayingMovies(page: currentPage)
                currentPage += 1
                self.totalPages = movieResponse.totalPages
                
                let uniqueMovies = movieResponse.results.filter { newMovie in
                    !movies.contains(where: { $0.id == newMovie.id })
                }
                
                if reset {
                    movies = uniqueMovies
                } else {
                    movies.append(contentsOf: uniqueMovies)
                }
                self.totalPages = movieResponse.totalPages
                self.isLoading = false
                onLoadingStateChange?(false)
            } catch let error as APIError {
                handleFetchError(error: error)
            } catch {
                handleUnexpectedError(error: error)
            }
        }
    }

    func refreshMovies() {
        fetchMovies(reset: true)
    }
    
    private func resetPagination() {
        currentPage = 1
        movies = []
    }
    
    private func handleFetchError(error: APIError) {
        isLoading = false
        onLoadingStateChange?(false)
        onError?(error.errorDescription ?? "An unexpected error occurred.")
    }

    private func handleUnexpectedError(error: Error) {
        isLoading = false
        onLoadingStateChange?(false)
        onError?("An unexpected error occurred: \(error.localizedDescription)")
    }
}
