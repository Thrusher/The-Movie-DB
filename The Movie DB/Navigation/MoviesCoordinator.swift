//
//  MoviesCoordinator.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

class MoviesCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMovies()
    }
    
    func showMovies() {
        let movieService = MovieService()
        let imageCacheService = ImageService()
        let favoritesManager = FavoritesManager()
        let viewModel = MoviesViewModel(
            movieService: movieService,
            imageService: imageCacheService,
            favoritesManager: favoritesManager
        )
        let moviesViewController = MoviesViewController(viewModel: viewModel)
        moviesViewController.didSelectMovie = { [weak self] movie in
            self?.showMovieDetails(
                movie,
                imageService: imageCacheService,
                favoritesManager: favoritesManager
            )
        }
        navigationController.pushViewController(
            moviesViewController,
            animated: true
        )
    }
    
    private func showMovieDetails(
        _ movie: Movie,
        imageService: ImageService,
        favoritesManager: FavoritesManager
    ) {
        let detailsViewController = MovieDetailsViewController(
            movie: movie,
            imageService: imageService,
            favoritesManager: favoritesManager
        )
        navigationController.pushViewController(
            detailsViewController,
            animated: true
        )
    }
}

