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

final class ImageService: ImageServiceProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    private func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: NSString(string: key))
    }
    
    private func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let cachedImage = getImage(forKey: urlString) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
                return
            }
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self, let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                self.setImage(image, forKey: urlString)
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }
}
