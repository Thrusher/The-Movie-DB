//
//  MoviesViewController.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

final class MoviesViewController: UICollectionViewController {

    private let viewModel: MoviesViewModel
    private weak var loaderView: LoaderView?
    
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
    
    private func showLoaderView() {
        let loaderView = LoaderView()
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)

        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.loaderView = loaderView
    }
    
    private func removeLoderView() {
        loaderView?.removeFromSuperview()
    }

    private func bindViewModel() {
        viewModel.onMoviesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }

        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.showErrorAlert(message: error, showRetryButton: self.viewModel.movies.isEmpty) {
                    self.viewModel.fetchMovies()
                }
            }
        }
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self else { return }
            DispatchQueue.main.async {
                if isLoading {
                    self.showLoaderView()
                } else {
                    self.removeLoderView()
                }
            }
        }
    }
    
    private func showErrorAlert(message: String, showRetryButton: Bool = false, retryAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if showRetryButton {
            let retryButton = UIAlertAction(title: "Retry", style: .default) { _ in
                retryAction?()
            }
            alert.addAction(retryButton)
        }
        
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
        cell.configure(with: movie, imageService: viewModel.imageService)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        didSelectMovie?(movie)
    }
}
