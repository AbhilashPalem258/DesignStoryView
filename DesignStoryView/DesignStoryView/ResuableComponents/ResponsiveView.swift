//
//  ResponsiveView.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//
import SwiftUI
import Foundation

struct ResponseView<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSize
    @Environment(\.verticalSizeClass) private var verticalSize
    
    let content: (Properties) -> Content
    var body: some View {
        GeometryReader { proxy in
            let props = Properties(sizeClass: .init(horizontal: horizontalSize, vertical: verticalSize), size: proxy.size, safeAreaInsets: proxy.safeAreaInsets)
            content(props)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    struct Properties {
        let sizeClass: SizeClass
        let size: CGSize
        let safeAreaInsets: EdgeInsets
    }
}

enum SizeClass {
    case compactWidthRegularHeight
    case compactWidthCompactHeight
    case regularWidthCompactHeight
    case regularWidthRegularHeight
    
    init(horizontal: UserInterfaceSizeClass?, vertical: UserInterfaceSizeClass?) {
        switch (horizontal, vertical) {
        case (.compact, .compact):
            self = SizeClass.compactWidthCompactHeight
        case (.compact, .regular):
            self = SizeClass.compactWidthRegularHeight
        case (.regular, .compact):
            self = SizeClass.regularWidthCompactHeight
        case (.regular, .regular):
            self = SizeClass.regularWidthRegularHeight
        default:
            self = SizeClass.compactWidthRegularHeight
            break
        }
    }
}
