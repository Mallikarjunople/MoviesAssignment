//
//  ImageLoader.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func load(url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) { return cached }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let img = UIImage(data: data) else { return nil }
            cache.setObject(img, forKey: url as NSURL)
            return img
        } catch {
            return nil
        }
    }
}
