//
//  PinterestLayout.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 12/10/24.
//
import SwiftUI

struct PinterestLayout<Content: View, ItemCollection: RandomAccessCollection<StoryBundleMetadata>>: View {
    
    private var items: [PinterestItem]
    var spacing: CGFloat = 8.0
    @ViewBuilder var content: (ItemCollection.Element, Int) -> Content
    
    private var columns: [PinterestColumn] = []
    
    init(
        items: ItemCollection,
        numberOfColumns: Int,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (ItemCollection.Element, Int) -> Content
    ) {
        self.items = items.map{ .init(element: $0) }
        self.spacing = spacing
        self.columns = (0..<numberOfColumns).map { _ in PinterestColumn() }
        self.content = content
        self.constructColumns(numberOfColumns: numberOfColumns)
    }
        
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(columns) { column in
                    LazyVStack {
                        ForEach(column.items) { item in
                            content(item.element, item.height)
                        }
                    }
                }
            }
        }
    }
    
    mutating func constructColumns(numberOfColumns: Int) {
        var columnHeights = Array(repeating: 0, count: numberOfColumns)
        
        for item in items {
            var smallestColumnIndex = 0
            for columnIndex in 0..<columnHeights.count where columnHeights[columnIndex] < columnHeights[smallestColumnIndex] {
                smallestColumnIndex = columnIndex
            }
            
            columnHeights[smallestColumnIndex] += item.height
            self.columns[smallestColumnIndex].items.append(item)
        }
    }
    
    fileprivate struct PinterestColumn: Identifiable {
        let id = UUID()
        var items: [PinterestItem] = []
    }
    
    fileprivate struct PinterestItem: Identifiable {
        let id = UUID()
        let element: StoryBundleMetadata
        let height: Int = Int.random(in: 100..<500)
    }
}
