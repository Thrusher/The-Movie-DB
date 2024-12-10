//
//  AppCoordinator.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var moviesCoordinator: MoviesCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let moviesCoordinator = MoviesCoordinator(navigationController: navigationController)
        self.moviesCoordinator = moviesCoordinator
        moviesCoordinator.start()
    }
}
