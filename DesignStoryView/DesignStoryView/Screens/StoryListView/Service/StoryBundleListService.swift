//
//  StoryBundleListService.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//

import Combine
import Foundation

protocol StoryBundleListDataProvidable {
    static func fetchStoriesBundleMetaData() -> AnyPublisher<[StoryBundleMetadata], Error>
    static func fetchSingleStoryBundle(StoryBundleMetadata: StoryBundleMetadata) -> AnyPublisher<Data, Error>
}

enum StoryBundleListDataProvider: StoryBundleListDataProvidable {
    static func fetchStoriesBundleMetaData() -> AnyPublisher<[StoryBundleMetadata], any Error> {
        let urlString = "https://picsum.photos/v2/list?page=2&limit=100"
        return NetworkService.fetch(url: urlString, type: [StoryBundleMetadata].self)
    }
    
    static func fetchSingleStoryBundle(StoryBundleMetadata: StoryBundleMetadata) -> AnyPublisher<Data, Error> {
        NetworkService.fetchResource(url: StoryBundleMetadata.url)
    }
}
