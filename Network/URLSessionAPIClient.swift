//
//  URLSessionAPIClient.swift
//  CombineNetworkLayer
//
//  Created by Anton Shvets on 21.03.2024.
//

import Foundation
import Combine

final class URLSessionAPIClient<EndpointType: APIEndpoint>: APIClient {
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error> {
        guard let baseURL = endpoint.baseURL else {
            return Fail(error: APIClientError.invalidURL).eraseToAnyPublisher()
        }
        
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        endpoint.headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        // set up any other request parameters here
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> T in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIClientError.invalidServerResponse
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIClientError.apiError(reason: .unauthorized)
                case 403:
                    throw APIClientError.apiError(reason: .resourceForbidden)
                case 404:
                    throw APIClientError.apiError(reason: .resourceNotFound)
                case 405..<500:
                    throw APIClientError.apiError(reason: .clientError)
                case 500..<600:
                    throw APIClientError.apiError(reason: .serverError)
                default:
                    break
                }
                
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    throw APIClientError.parserError(reason: .decodingError)
                }
                
                return decodedData
            }
            .mapError { error in
                // if it's our kind of error already, we can return it directly
                if let error = error as? APIClientError {
                    return error
                }
                // if it is a URLError, we can convert it into our more general error kind
                if let urlError = error as? URLError {
                    return APIClientError.networkError(from: urlError)
                }
                // if all else fails, return the unknown error condition
                return APIClientError.unknown
            }
            .eraseToAnyPublisher()
    }
}
