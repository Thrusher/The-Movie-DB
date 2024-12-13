//
//  MoviesViewModel.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

protocol MoviesViewModelDelegate: AnyObject {
    func moviesViewModel(_ viewModel: MoviesViewModel, didUpdateMovies movieCellModels: [MovieCellViewModel])
    func moviesViewModel(_ viewModel: MoviesViewModel, didEncounterError error: String)
    func moviesViewModel(_ viewModel: MoviesViewModel, didChangeLoadingState isLoading: Bool)
}

final class MoviesViewModel {
    let movieService: MovieServiceProtocol
    let imageService: ImageServiceProtocol
    let favoritesManager: FavoritesManagerProtocol
    
    private var currentPage = 1
    private var totalPages = 1

    private var isLoading = false {
        didSet {
            self.delegate?.moviesViewModel(self, didChangeLoadingState: isLoading)
        }
    }

    private(set) var movies: [Movie] = [] {
        didSet {
            createCellViewModels(from: movies)
        }
    }
    
    private(set) var movieCellModels: [MovieCellViewModel] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.moviesViewModel(self, didUpdateMovies: self.movieCellModels)
            }
        }
    }
    
    weak var delegate: MoviesViewModelDelegate?
    
    init(movieService: MovieServiceProtocol,
         imageService: ImageServiceProtocol,
         favoritesManager: FavoritesManagerProtocol) {
        self.movieService = movieService
        self.imageService = imageService
        self.favoritesManager = favoritesManager
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
                
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
            } catch let error as APIError {
                self.handleError(errorDescription: error.errorDescription ?? "An unexpected error occurred.")
            } catch {
                self.handleError(errorDescription: "An unexpected error occurred: \(error.localizedDescription)")
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
    
    private func handleError(errorDescription: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isLoading = false
            self.delegate?.moviesViewModel(self, didEncounterError: errorDescription)
        }
    }
    
    private func createCellViewModels(from movies: [Movie]) {
        movieCellModels = movies.map { movie in
            MovieCellViewModel(movie: movie, imageService: imageService, favoritesManager: favoritesManager)
        }
    }
}
