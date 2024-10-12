//
//  StoryListViewModel.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//
import Observation
import Combine

@Observable
class StoryListViewModel {
    
    var state: DataState = .init()
    var presentedRoute: StoryBundleListCoordinator.Routes?
    
    struct DataState {
        var status: Status = .fetching
        var storyMetadataList = [StoryBundleMetadata]()
        
        enum Status {
            case fetching
            case success
            case failure(Error)
        }
    }
    
    private var storyFetchTask: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    let dataProvider: StoryBundleListDataProvidable.Type
    init(dataProvider: StoryBundleListDataProvidable.Type = StoryBundleListDataProvider.self) {
        self.dataProvider = dataProvider
    }
    
    func fetchStories() {
        state.status = .fetching
        storyFetchTask?.cancel()
        storyFetchTask = dataProvider.fetchStoriesBundleMetaData()
            .sink {[weak self] completion in
                if case let .failure(error) = completion {
                    self?.state.status = .failure(error)
                }
            } receiveValue: {[weak self] storiesBundle in
                self?.state.status = .success
                self?.state.storyMetadataList += storiesBundle
            }
    }
}
