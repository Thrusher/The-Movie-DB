//
//  ImageCache.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 11/12/2024.
//

import UIKit

protocol ImageServiceProtocol {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
}

class ImageService: ImageServiceProtocol {
    private let cache = NSCache<NSString, UIImage>()

    private func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: NSString(string: key))
    }

    private func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = getImage(forKey: urlString) {
            completion(cachedImage)
            return
        }
        
        // Download image if not in cache
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Cache the image
            self.setImage(image, forKey: urlString)
            completion(image)
        }.resume()
    }
}
