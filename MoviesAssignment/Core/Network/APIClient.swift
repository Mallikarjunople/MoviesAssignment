//
//  APIClient.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import Foundation

actor TMDBClient {
    static let shared = TMDBClient()
    private init() {}

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard var comp = URLComponents(string: Config.baseURL + path) else { return nil }
        var items = queryItems
        items.append(URLQueryItem(name: "api_key", value: Config.apiKey))
        comp.queryItems = items
        return comp.url
    }

    private func request<T: Decodable>(_ url: URL) async throws -> T {
        var req = URLRequest(url: url)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw APIError.emptyData }
            guard (200...299).contains(http.statusCode) else { throw APIError.serverError(statusCode: http.statusCode, data: data) }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            if let api = error as? APIError { throw api }
            throw APIError.unknownError(error)
        }
    }

    // Public methods
    func fetchPopular() async throws -> [Movie] {
        guard let url = makeURL(path: "/movie/popular") else { throw APIError.invalidURL }
        let resp: MovieResponse = try await request(url)
        return resp.results ?? []
    }

    func search(query: String) async throws -> [Movie] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        guard let url = makeURL(path: "/search/movie", queryItems: [URLQueryItem(name: "query", value: trimmed)]) else { throw APIError.invalidURL }
        let resp: MovieResponse = try await request(url)
        return resp.results ?? []
    }

    func fetchDetails(movieId: Int) async throws -> MovieDetails {
        guard let url = makeURL(path: "/movie/\(movieId)") else { throw APIError.invalidURL }
        return try await request(url)
    }

    func fetchVideos(movieId: Int) async throws -> [Video] {
        guard let url = makeURL(path: "/movie/\(movieId)/videos") else { throw APIError.invalidURL }
        let resp: VideoResponse = try await request(url)
        return resp.results ?? []
    }
}

