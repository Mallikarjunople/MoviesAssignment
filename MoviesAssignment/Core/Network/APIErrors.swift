//
//  APIErrors.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case unknownError(Error)
    case serverError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .unknownError(let e): return "Network error: \(e.localizedDescription)"
        case .serverError(let code, _): return "Server error: status code \(code)"
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .emptyData: return "No data received from server"
        }
    }
}
