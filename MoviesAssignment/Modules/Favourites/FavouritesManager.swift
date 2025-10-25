//
//  FavouritesManager.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import Foundation

final class FavoritesManager {
    static let shared = FavoritesManager()
    private let key = "favorites_ids_v1"
    private var set: Set<Int>

    private init() {
        if let arr = UserDefaults.standard.array(forKey: key) as? [Int] {
            set = Set(arr)
        } else {
            set = []
        }
    }

    func isFavorite(_ id: Int) -> Bool {
        set.contains(id)
    }

    func toggle(_ id: Int) {
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(set), forKey: key)
    }
}
