//
//  FavoritesManager.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 12/12/2024.
//

import Foundation

protocol FavoritesManagerProtocol {
    func isFavorite(movieID: Int) -> Bool
    func toggleFavorite(movieID: Int)
}

final class FavoritesManager: FavoritesManagerProtocol {
    private let favoritesKey = "favoriteMovies"
    private let defaults = UserDefaults.standard
            
    func isFavorite(movieID: Int) -> Bool {
        let favorites = defaults.array(forKey: favoritesKey) as? [Int] ?? []
        return favorites.contains(movieID)
    }
    
    func toggleFavorite(movieID: Int) {
        var favorites = defaults.array(forKey: favoritesKey) as? [Int] ?? []
        let indexOfFavoriteMovie = favorites.firstIndex(of: movieID)
        if let index = indexOfFavoriteMovie {
            favorites.remove(at: index)
        } else {
            favorites.append(movieID)
        }
        defaults.set(favorites, forKey: favoritesKey)
        NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil, userInfo: ["movieID": movieID])
    }
}

extension Notification.Name {
    static let favoriteStatusChanged = Notification.Name("favoriteStatusChanged")
}
