//
//  APIError.swift
//  CombineNetworkLayer
//
//  Created by Anton Shvets on 21.03.2024.
//

import Foundation

enum APIClientError: Error, LocalizedError {
    enum ParserError: Error {
        case decodingError
    }
    
    enum APIError: Error {
        case unauthorized
        case resourceForbidden
        case resourceNotFound
        case clientError
        case serverError
    }
    
    case unknown
    case invalidURL
    case invalidServerResponse
    
    case apiError(reason: APIError)
    case parserError(reason: ParserError)
    case networkError(from: URLError)
}
