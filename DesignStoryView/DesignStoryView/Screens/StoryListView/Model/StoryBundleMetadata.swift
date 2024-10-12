//
//  StoryBundle.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//
import Foundation
import UIKit

struct StoryBundleMetadata: Decodable, Identifiable, Hashable {
    let id: String
    let author: String
    let url: URL
    let downloadUrl: URL
    
    enum CodingKeys: CodingKey {
        case id
        case author
        case url
        case downloadUrl
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.author = try container.decode(String.self, forKey: .author)
        self.url = try container.decode(URL.self, forKey: .url)
        var downloadUrl = try container.decode(String.self, forKey: .downloadUrl)
        
        var components = downloadUrl.components(separatedBy: "/")
        components.removeLast(2)
        components.append("150")
        components.append("150")
        let urlString = components.joined(separator: "/")
        self.downloadUrl = URL(string: urlString) ?? URL(fileURLWithPath: "")
    }
}
// https://picsum.photos/v2/list?page=2&limit=100
