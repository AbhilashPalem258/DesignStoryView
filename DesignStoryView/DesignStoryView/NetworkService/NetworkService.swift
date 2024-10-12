//
//  NetworkService.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//

import Foundation
import Combine

enum NetworkService {
    static func fetch<T: Decodable>(url: String, type: T.Type) -> AnyPublisher<T, Error> {
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap { (data, response) in
                if let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300, let mimeType = response.mimeType, mimeType == "application/json" {
                    return data
                }
                throw URLError(.badServerResponse)
            }
            .decode(type: type, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private static var resourceCache: URLCache = {
        var fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        fileURL?.append(component: "Resources")
        return URLCache(memoryCapacity: 50_000_000, diskCapacity: 100_000_000, diskPath: fileURL?.path())
    }()
    
    static func fetchResource(url: URL) -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: url)
        if let cache = resourceCache.cachedResponse(for: request) {
            return Just(cache.data).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap { (data, response) in
                if let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 {
                    resourceCache.storeCachedResponse(.init(response: response, data: data), for: request)
                    return data
                }
                throw URLError(.badServerResponse)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
