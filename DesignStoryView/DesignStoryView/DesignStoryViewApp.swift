//
//  DesignStoryViewApp.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 08/10/24.
//

import SwiftUI

@main
struct DesignStoryViewApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StoryBundleListCoordinator()
            }
            .preferredColorScheme(.dark)
            .onAppear {
                print("Cache directory: \(FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0])")
            }
        }
    }
}
