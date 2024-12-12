//
//  UIImageViewExtensions.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 12/12/2024.
//

import UIKit

extension UIImageView {
    func loadImage(from urlString: String, using imageService: ImageServiceProtocol, placeholder: UIImage? = nil) {
        imageService.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image ?? placeholder
            }
        }
    }
}
