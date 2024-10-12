//
//  StoryDetailViewCoordinator.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//
import SwiftUI

struct StoryDetailViewCoordinator: View {
    let storybundle: StoryBundleMetadata
    
    var body: some View {
        ResponseView { props in
            StoryDetailView(storybundle: storybundle)
        }
    }
}
