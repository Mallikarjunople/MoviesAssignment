//
//  MovieModel.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import Foundation

struct Config {
    static let apiKey = "ab881522619671c495322a22e089efe4"
    static let imageBase = "https://image.tmdb.org/t/p/w500"
    static let baseURL = "https://api.themoviedb.org/3"
}

// MARK: - Models

struct MovieDetails: Codable {
    let id: Int?
    let title: String?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    let runtime: Int?
    let genres: [Genre]?

    var formattedDuration: String {
        guard let runtime = runtime else { return "N/A" }
        return "\(runtime / 60)h \(runtime % 60)m"
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }
}

struct Genre: Codable {
    let id: Int?
    let name: String?
}

struct VideoResponse: Codable {
    let id: Int?
    let results: [Video]?
}

struct Video: Codable, Equatable {
    let id: String?
    let key: String?
    let name: String?
    let site: String?
    let type: String?

    var youtubeURL: URL? {
        URL(string: "https://www.youtube.com/embed/\(key ?? "")")
    }
}

