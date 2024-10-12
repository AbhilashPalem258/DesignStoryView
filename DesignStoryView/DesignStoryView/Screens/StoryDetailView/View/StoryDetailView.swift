//
//  StoryDetailView.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 10/10/24.
//

import SwiftUI

struct StoryDetailView: View {
    
    let storybundle: StoryBundleMetadata
    @Environment(\.dismiss) private var dismiss
    
    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
            }
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body.bold())
            }
        }
        .overlay {
            Text("Abhilash")
                .font(.title.bold())
        }
        .tint(.primary)
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }
    
    private var storyView: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ScrollView(.horizontal) {
                LazyHStack {
                    StoryBundleDetailImageView(viewModel: .init(storyBundle: storybundle), cornerRadius: 10, size: size)
                        .containerRelativeFrame(.horizontal)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
        }
    }
    
    var body: some View {
        VStack {
            navigationBar
            storyView
        }
        .hideNavtionBar()
    }
}

struct StoryBundleDetailImageView: View {
    
    @State var viewModel: GridStoryBundleViewModel
    let cornerRadius: CGFloat
    let size: CGSize
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if let data = viewModel.image, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: cornerRadius))
                    .contentShape(.rect)
                    .onTapGesture {
                        onTap?()
                    }
            } else {
                Color.clear
                    .onAppear
                    {
                        viewModel.fetchImage()
                    }
            }
        }
        .frame(width: size.width, height: size.height)
    }
}
