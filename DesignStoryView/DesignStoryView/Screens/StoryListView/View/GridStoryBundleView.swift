//
//  GridStoryBundleView.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//

import SwiftUI
import Combine

@Observable
class GridStoryBundleViewModel {
    
    let storyBundle: StoryBundleMetadata
    var image: Data?
    private var fetchImagetask: AnyCancellable?
    
    init(storyBundle: StoryBundleMetadata) {
        self.storyBundle = storyBundle
    }
    
    func fetchImage() {
        guard image.isNil else { return }
        fetchImagetask?.cancel()
        fetchImagetask = NetworkService.fetchResource(url: storyBundle.downloadUrl)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("error: \(error)")
                case .finished:
                    print("Downloaded")
                }
            } receiveValue: {[weak self] data in
                self?.image = data
            }
    }
}

struct GridStoryBundleView: View {
        
    var viewModel: GridStoryBundleViewModel
    let height: CGFloat?
    let cornerRadius: CGFloat
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            Rectangle()
                .fill(.clear)
            
            if let data = viewModel.image, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipShape(.rect(cornerRadius: cornerRadius))
                    .contentShape(.rect)
                    .onTapGesture {
                        onTap?()
                    }
            }
        }
        .frame(height: height)
        .onAppear {
            viewModel.fetchImage()
        }
    }
}
