//
//  APIClient.swift
//  CombineNetworkLayer
//
//  Created by Anton Shvets on 21.03.2024.
//

import Combine

protocol APIClient {
    associatedtype EndpointType: APIEndpoint
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error>
}
