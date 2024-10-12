//
//  CompositionalLayout.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 11/10/24.
//

import SwiftUI

struct CompositionalLayout<Content: View>: View {
    var count: Int = 3
    var spacing: CGFloat = 8
    @ViewBuilder var content: Content
    var body: some View {
        Group(subviews: content) { collection in
            let chunked = collection.chunked(count)
            
            ForEach(chunked) { section in
                let layoutId = section.layoutId
                switch layoutId {
                case 0:
                    layout1(section.collection)
                case 1:
                    layout2(section.collection)
                case 2:
                    layout3(section.collection)
                default:
                    layout4(section.collection)
                }
            }
        }
    }
    
    
    func layout1(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width - spacing
            
            HStack(spacing: spacing) {
                if let first = collection.first {
                    first
                }
                
                VStack(spacing: spacing) {
                    ForEach(collection.dropFirst()) { subview in
                        subview
                            .frame(width: width * 0.33)
                    }
                }
            }
        }
        .frame(height: 300)
    }
    
    func layout2(_ collection: [SubviewsCollection.Element]) -> some View {
        HStack(spacing: spacing) {
            ForEach(collection) { subview in
                subview
            }
        }
        .frame(height: 150)
    }
    
    func layout3(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width - spacing

            HStack(spacing: spacing) {
                let last = collection.last
                VStack(spacing: spacing) {
                    ForEach(collection.dropLast()) { subview in
                        subview
                            .frame(width: width * 0.33)
                    }
                }
                
                if let last {
                    last
                }
            }
        }
        .frame(height: 300)
    }
    
    func layout4(_ collection: [SubviewsCollection.Element]) -> some View {
        HStack(spacing: spacing) {
            ForEach(collection.dropFirst()) { subview in
                subview
            }
        }
        .frame(height: 230)
    }
}
fileprivate extension SubviewsCollection {
    func chunked(_ size: Int) -> [ChunkedCollection] {
        stride(from: 0, to: count, by: size).map {
            let collection = Array(self[$0..<Swift.min($0+size, count)])
            let layoutId = ($0/size) % 4
            return ChunkedCollection(layoutId: layoutId, collection: collection)
        }
    }
    
    struct ChunkedCollection: Identifiable {
        let id = UUID()
        let layoutId: Int
        let collection: [SubviewsCollection.Element]
    }
}
 
