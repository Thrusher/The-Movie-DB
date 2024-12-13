//
//  Movie Details.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let maxPosterHeight: CGFloat = 300
        static let posterAspectRatio: CGFloat = 0.75
        static let sidePadding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let largeSpacing: CGFloat = 16
    }

    // MARK: - Properties
    private let movie: Movie
    private let imageService: ImageServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    
    private var isFavorite: Bool {
        favoritesManager.isFavorite(movieID: movie.id)
    }

    // MARK: - UI Elements
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(movie: Movie, imageService: ImageServiceProtocol, favoritesManager: FavoritesManagerProtocol) {
        self.movie = movie
        self.imageService = imageService
        self.favoritesManager = favoritesManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        configure(with: movie, imageService: imageService)
    }
    
    // MARK: - Setup UI
    private func setupNavigationBar() {
        updateFavoriteButton()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(overviewLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: Layout.posterAspectRatio),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Layout.largeSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sidePadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sidePadding),

            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.spacing),
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            ratingLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: Layout.spacing),
            ratingLabel.leadingAnchor.constraint(equalTo: releaseDateLabel.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: releaseDateLabel.trailingAnchor),

            overviewLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: Layout.largeSpacing),
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.largeSpacing)
        ])
    }

    // MARK: - Configure
    private func configure(with movie: Movie, imageService: ImageServiceProtocol) {
        titleLabel.text = movie.title
        releaseDateLabel.text = "Release Date: \(movie.releaseDate ?? "N/A")"
        ratingLabel.text = "Rating: \(movie.voteAverage ?? 0)/10"
        overviewLabel.text = movie.overview

        let placeholderImage = UIImage(systemName: "film")
        if let backdropPath = movie.backdropPath {
            posterImageView.loadImage(from: "https://image.tmdb.org/t/p/w500\(backdropPath)",
                                      using: imageService,
                                      placeholder: placeholderImage)
        } else {
            posterImageView.image = placeholderImage
        }
    }
    
    private func updateFavoriteButton() {
        let favoriteIcon = isFavorite ? "star.fill" : "star"
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: favoriteIcon),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = favoriteButton
    }

    // MARK: - Button Actions
    @objc private func favoriteButtonTapped() {
        favoritesManager.toggleFavorite(movieID: movie.id)
        updateFavoriteButton()
    }
}

