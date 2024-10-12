//
//  StoryBundleListCoordinator.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//
import SwiftUI

struct StoryBundleListCoordinator: View {
    
    enum Routes: Hashable {
        case storyBundleDetail(StoryBundleMetadata)
    }
    
    @State private var viewModel = StoryListViewModel()
    
    var body: some View {
        ResponseView { props in
            StoryBundleListView(viewModel: viewModel)
        }
        .navigationDestination(item: $viewModel.presentedRoute) { route in
            switch route {
            case .storyBundleDetail(let storyBundle):
                storyBundleDetailCoordinator(storyBundle)
            }
        }
    }
    
    func storyBundleDetailCoordinator(_ storyBundle: StoryBundleMetadata) -> some View {
        StoryDetailView(storybundle: storyBundle)
    }
}
