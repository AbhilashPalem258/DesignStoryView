//
//  View+Extensions.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 09/10/24.
//
import SwiftUI

extension View {
    func hideNavtionBar() -> some View {
        toolbarVisibility(.hidden, for: .navigationBar)
    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
