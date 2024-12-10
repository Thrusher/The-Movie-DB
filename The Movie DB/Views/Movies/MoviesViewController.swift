//
//  MoviesViewController.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

class MoviesViewController: UICollectionViewController {

    private let viewModel: MoviesViewModel
    var didSelectMovie: ((Movie) -> Void)?

    init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: .createCompositionalLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        setupCollectionView()
        bindViewModel()
        viewModel.fetchMovies()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.cellIdentifier)
    }

    private func bindViewModel() {
        viewModel.onMoviesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }

        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: error)
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MoviesViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.cellIdentifier, for: indexPath) as! MovieCell
        let movie = viewModel.movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        didSelectMovie?(movie)
    }
}
