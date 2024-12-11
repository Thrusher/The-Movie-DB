//
//  Movie Details.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import UIKit

final class MovieDetailsViewController: UIViewController {
    private let movie: Movie

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = movie.title

        let label = UILabel()
        label.text = movie.overview
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.frame = view.bounds.insetBy(dx: 16, dy: 16)
        view.addSubview(label)
    }
}
