//
//  ContentView.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 08/10/24.
//

import SwiftUI

struct StoryListView: View {
    
    @State private var items = [Color.red, Color.green, Color.blue, Color.yellow, Color.purple, Color.brown]
    @State private var showDetail: Bool = false
    @State private var selectedItem: Color?
    
    private var title: some View {
        Text("Stories")
            .font(.largeTitle.bold())
    }
    
    private var storiesList: some View {
        let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 8), count: 2)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items, id: \.self) { item in
                GridStoryView(item: item)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                title
                storiesList
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .hideNavtionBar()
        .navigationDestination(for: Color.self) { item in
            DetailView(item: item)
        }
    }
}

struct GridStoryView: View {
    let item: Color
    @State private var showDetail: Bool = false
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            SourceView(id: item.description) {
                item
                    .frame(height: size.height)
                    .cornerRadius(5.0)
            }
            .contentShape(.rect)
            .storyTransition(id: item.description, animate: $showDetail) {
                item
                    .frame(height: size.height)
                    .cornerRadius(5.0)
            } completion: { status in
                print("Navigation Completed")
            }
            .onTapGesture {
                showDetail = true
            }
            .navigationDestination(isPresented: $showDetail) {
                DetailView(item: item)
            }
        }
        .frame(height: 320)
    }
}

struct DetailView: View {
    let item: Color
    var body: some View {
        VStack {
            DestinationView(id: item.description) {
                item
                    .frame(width: 300, height: 300)
                    .cornerRadius(5.0)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoryListView()
    }
}
