//
//  MoviesViewController.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

final class MoviesViewController: UICollectionViewController {
    
    enum MoviesSection: Hashable {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<MoviesSection, Movie>!

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
        setupRefreshControl()
        setupDataSource()
        bindViewModel()
        viewModel.fetchMovies()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 100 {
            viewModel.fetchMovies()
        }
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.cellIdentifier)
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MoviesSection, Movie>(collectionView: collectionView) { collectionView, indexPath, movie in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.cellIdentifier, for: indexPath) as! MovieCell
            let movie = self.viewModel.movies[indexPath.row]
            cell.configure(with: movie, imageService: self.viewModel.imageService)
            return cell
        }
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
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        let movieIDs = viewModel.movies.map { $0.id }
        let duplicates = movieIDs.filter { id in
            movieIDs.filter { $0 == id }.count > 1
        }

        assert(duplicates.isEmpty, "Duplicate movie IDs found: \(duplicates)")
        
        var snapshot = NSDiffableDataSourceSnapshot<MoviesSection, Movie>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.movies, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func bindViewModel() {
        viewModel.onMoviesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.applySnapshot()
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
                self.updateRefreshControl(isLoading: isLoading)
                self.updateLoaderView(
                    isLoading: isLoading,
                    areMoviesEmpty: self.viewModel.movies.isEmpty
                )
            }
        }
    }
    
    private func updateLoaderView(isLoading: Bool, areMoviesEmpty: Bool) {
        if isLoading && self.viewModel.movies.isEmpty {
            self.showLoaderView()
        } else {
            self.removeLoderView()
        }
    }
    
    private func updateRefreshControl(isLoading: Bool) {
        if let refreshControl = self.collectionView.refreshControl {
            if !isLoading && refreshControl.isRefreshing {
                self.collectionView.refreshControl?.endRefreshing()
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
    
    @objc private func refreshMovies() {
        viewModel.refreshMovies()
    }
}

extension MoviesViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        didSelectMovie?(movie)
    }
}
