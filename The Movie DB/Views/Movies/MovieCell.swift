//
//  MovieCell.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 10/12/2024.
//

import UIKit

final class MovieCell: UICollectionViewCell {
    
    static let cellIdentifier = "MovieCell"
    
    var onFavoriteTapped: (() -> Void)?
    
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
        button.tintColor = .systemRed
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
    func configure(with movie: Movie, imageService: ImageServiceProtocol) {
        activityIndicator.startAnimating()

        posterImageView.image = nil

        if let posterPath = movie.posterPath {
            let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            imageService.loadImage(from: urlString) { [weak self] image in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.posterImageView.image = image ?? UIImage(systemName: "film")
                }
            }
        } else {
            activityIndicator.stopAnimating()
            posterImageView.image = UIImage(systemName: "film")
        }
        
        //TODO: - Fix it when database will be ready
//        let favoriteIcon = movie.isFavorite ? "heart.fill" : "heart"
        let favoriteIcon = "heart.fill"
        favoriteButton.setImage(UIImage(systemName: favoriteIcon), for: .normal)
    }

    // MARK: - Button Actions
    @objc private func favoriteButtonTapped() {
        onFavoriteTapped?()
    }
}
