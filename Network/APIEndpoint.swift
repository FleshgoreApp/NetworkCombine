//
//  APIEndpoint.swift
//  CombineNetworkLayer
//
//  Created by Anton Shvets on 21.03.2024.
//

import Foundation

protocol APIEndpoint {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}
