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
        let imageCacheService = ImageService()
        let movieService = MovieService(apiClient: APIClient())
        let viewModel = MoviesViewModel(movieService: movieService,
                                        imageService: imageCacheService)
        let moviesViewController = MoviesViewController(viewModel: viewModel)
        moviesViewController.didSelectMovie = { [weak self] movie in
            self?.showMovieDetails(movie)
        }
        navigationController.pushViewController(moviesViewController, animated: true)
    }

    private func showMovieDetails(_ movie: Movie) {
        let detailsViewController = MovieDetailsViewController(movie: movie)
        navigationController.pushViewController(detailsViewController, animated: true)
    }
}

