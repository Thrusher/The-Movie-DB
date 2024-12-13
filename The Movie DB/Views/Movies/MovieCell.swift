//
//  MovieCell.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 10/12/2024.
//

import UIKit

final class MovieCell: UICollectionViewCell {
        
    var viewModel: MovieCellViewModel?
        
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addNotificationObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(activityIndicator)

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.5),

            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor)
        ])
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    // MARK: - Configuration
    func configure(with viewModel: MovieCellViewModel) {
        if self.viewModel != viewModel {
            activityIndicator.startAnimating()
            posterImageView.image = nil
        }
        self.viewModel = viewModel

        favoriteButton.setImage(
            UIImage(systemName: viewModel.isFavorite ? "star.fill" : "star"),
            for: .normal
        )
        
        viewModel.loadPosterImage { [weak self] image in
            self?.posterImageView.image = image ?? UIImage(systemName: "film")
            self?.activityIndicator.stopAnimating()
        }
    }

    // MARK: - Button Actions
    @objc private func favoriteButtonTapped() {
        guard let viewModel else { return }
        viewModel.toggleFavorite()
//        configure(with: viewModel)
    }
    
    // MARK: - Notification Handling
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoriteStatusChanged(_:)),
            name: .favoriteStatusChanged,
            object: nil
        )
    }
    
    @objc private func handleFavoriteStatusChanged(_ notification: Notification) {
        guard let movieID = notification.userInfo?["movieID"] as? Int,
              let viewModel else {
            return
        }
        
        if viewModel.id == movieID {
            favoriteButton.setImage(
                UIImage(systemName: viewModel.isFavorite ? "star.fill" : "star"),
                for: .normal
            )
        }
    }
}

final class MovieCellViewModel: Equatable, Hashable {
    static let cellIdentifier = "MovieCell"
    
    private let movie: Movie
    private let imageService: ImageServiceProtocol
    private var favoritesManager: FavoritesManagerProtocol

    var id: Int {
        movie.id
    }
    
    var title: String {
        movie.title
    }

    var posterURL: String? {
        movie.posterPath.map { "https://image.tmdb.org/t/p/w500\($0)" }
    }

    var isFavorite: Bool {
        favoritesManager.isFavorite(movieID: id)
    }
    
    init(movie: Movie, imageService: ImageServiceProtocol, favoritesManager: FavoritesManagerProtocol) {
        self.movie = movie
        self.imageService = imageService
        self.favoritesManager = favoritesManager
    }

    func loadPosterImage(completion: @escaping (UIImage?) -> Void) {
        guard let posterURL = posterURL else {
            completion(nil)
            return
        }
        
        imageService.loadImage(from: posterURL, completion: completion)
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(movieID: movie.id)
    }
    
    // MARK: - Equatable Protocol
    static func == (lhs: MovieCellViewModel, rhs: MovieCellViewModel) -> Bool {
        return lhs.movie == rhs.movie
    }
    
    // MARK: - Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(movie)
    }
}
