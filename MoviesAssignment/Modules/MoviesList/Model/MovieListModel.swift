//
//  MovieListModel.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 25/10/25.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int?
    let results: [Movie]?
}

struct Movie: Codable, Equatable {
    let id: Int
    let title: String?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    let genreIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
}
