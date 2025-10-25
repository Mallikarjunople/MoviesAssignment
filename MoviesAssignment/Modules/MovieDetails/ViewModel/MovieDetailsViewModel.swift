//
//  MovieDetailsViewModel.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 25/10/25.
//

import Combine
import UIKit

final class MovieDetailsViewModel {

    var movieDetail: MovieDetails?
    var trailerURL: URL?
    var movieID: Int
    let dataFetchedPublisher: PassthroughSubject<Void, Never> = .init()
    let errorPublisher: PassthroughSubject<Error, Never> = .init()
    var cancellables = Set<AnyCancellable>()

    init(movieID: Int) {
        self.movieID = movieID
    }

    func fetchMovieDetailsData() async {
        do {
            async let movieDetail = TMDBClient.shared.fetchDetails(movieId: movieID)
            async let videos = TMDBClient.shared.fetchVideos(movieId: movieID)

            let (detail, videoResponse) = try await (movieDetail, videos)
            self.movieDetail = detail
            self.trailerURL = videoResponse.first(where: { $0.type == "Trailer" })?.youtubeURL
            dataFetchedPublisher.send()
        } catch {
            errorPublisher.send(error)

        }
    }
}
