//
//  StoryBundleListView.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//
import SwiftUI

struct StoryBundleListView: View {
    
    private let viewModel: StoryListViewModel
    private let layoutType: LayoutType
    init(viewModel: StoryListViewModel, layoutType: LayoutType = .pinterest) {
        self.layoutType = layoutType
        self.viewModel = viewModel
    }
    @State private var showCompositional: Bool = false
    @Namespace private var layoutTransition
    
    private var title: some View {
        Text("Stories")
            .font(.largeTitle.bold())
            .padding([.horizontal, .top], 15)
            .padding(.bottom, 10)
            .onTapGesture {
                viewModel.fetchStories()
            }
    }
    
    private func storiesList(_ stories: [StoryBundleMetadata]) -> any View {
        Group {
            switch layoutType {
            case .compositional:
                CompositionalLayout(count: 3, spacing: 8) {
                    ForEach(viewModel.state.storyMetadataList) { storyBundle in
                        GridStoryBundleView(viewModel: .init(storyBundle: storyBundle), height: nil, cornerRadius: 10.0) {
                            viewModel.presentedRoute = .storyBundleDetail(storyBundle)
                        }
                    }
                }
            case .grid:
                let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 8), count: 2)
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.state.storyMetadataList) { storyBundle in
                        GridStoryBundleView(viewModel: .init(storyBundle: storyBundle), height: 300, cornerRadius: 10.0) {
                            viewModel.presentedRoute = .storyBundleDetail(storyBundle)
                        }
                    }
                }
            default:
                PinterestLayout(items: stories, numberOfColumns: 2, spacing: 8.0) { item, height in
                    GridStoryBundleView(viewModel: .init(storyBundle: item), height: CGFloat(height), cornerRadius: 10.0) {
                        viewModel.presentedRoute = .storyBundleDetail(item)
                    }
                }
            }
        }
    }
    
    var mainContent: some View {
        Group {
            switch viewModel.state.status {
            case .fetching:
                ProgressView()
            case .success:
                ScrollView {
                    storiesList(viewModel.state.storyMetadataList)
                        .eraseToAnyView()
                }
                .scrollIndicators(.hidden)
            case .failure(let error):
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle.fill", description: Text(error.localizedDescription))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            title
            mainContent
            Spacer()
        }
        .padding(.horizontal)
        .hideNavtionBar()
        .onAppear {
            if viewModel.state.storyMetadataList.isEmpty {
                viewModel.fetchStories()
            }
        }
    }
    
    enum LayoutType {
        case grid
        case compositional
        case pinterest
    }
}
