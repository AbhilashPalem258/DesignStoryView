//
//  PhotoTransitionLayer.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 08/10/24.
//
import SwiftUI
import Foundation

struct StoryTransitionLayer<Content: View>: View {
    let content: () -> Content
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var overlayWindow: PassThroughWindow?
    @State private var storyTransitionModel = StoryTransitionModel()

    var body: some View {
        content()
            .onChange(of: scenePhase) { _, phase in
                if phase == .active, overlayWindow.isNil {
                    addOverlayWindow()
                }
            }
            .environment(storyTransitionModel)
    }
    
    func addOverlayWindow() {
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene, scene.activationState == .foregroundActive {
                
                let rootView = UIHostingController(rootView: StoryTransitionView().environment(storyTransitionModel))
                rootView.view.frame = windowScene.screen.bounds
                rootView.view.backgroundColor = .clear
                
                let window = PassThroughWindow(windowScene: windowScene)
                window.isUserInteractionEnabled = false
                window.backgroundColor = .clear
                window.rootViewController = rootView
                window.isHidden = false
                
                self.overlayWindow = window
            }
        }
    }
}

@Observable
class StoryTransitionModel {
    var items = [StoryTransition]()
    
    func index(_ id: String) -> Int? {
        guard let index = items.firstIndex(where: {$0.infoId == id}) else { return nil }
        return index
    }
    
    subscript(_ index: Int) -> StoryTransition {
        get {
            items[index]
        } set {
            items[index] = newValue
        }
    }
}

struct StoryTransition: Identifiable {
    let id: UUID = .init()
    let infoId: String
    var isActive: Bool = false
    var animateView: Bool = false
    var layerView: AnyView?
    var sourceAnchor: Anchor<CGRect>?
    var destinationAnchor: Anchor<CGRect>?
    var sourceCornerRadius: CGFloat = 0.0
    var destinationCornerRadius: CGFloat = 0.0
    var hideView: Bool = false
    var zIndex: Double = 0
    var completion: (Bool) -> Void = {_ in }
    
    init(infoId: String) {
        self.infoId = infoId
    }
}

extension View {
    func storyTransition<Content: View>(
        id: String,
        animate: Binding<Bool>,
        sourceCornerRadius: CGFloat = 0.0,
        destinationCornerRadius: CGFloat = 0.0,
        zIndex: Double = 0,
        content: @escaping () -> Content,
        completion: @escaping (Bool) -> Void
    ) -> some View {
        modifier(
            StoryTransitionLayerViewModifier(
                id: id,
                animate: animate,
                sourceCornerRadius: sourceCornerRadius,
                destinationCornerRadius: destinationCornerRadius,
                zIndex: zIndex,
                layerView: content,
                completion: completion
            )
        )
    }
}

struct StoryTransitionLayerViewModifier<Layer: View>: ViewModifier {
    
    let id: String
    @Binding var animate: Bool
    var sourceCornerRadius: CGFloat = 0.0
    var destinationCornerRadius: CGFloat = 0.0
    var zIndex: Double = 0
    var layerView: () -> Layer
    var completion: (Bool) -> Void
    
    @Environment(StoryTransitionModel.self) private var storyTransitionModel
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if storyTransitionModel.index(id).isNil {
                    storyTransitionModel.items.append(StoryTransition(infoId: id))
                }
            }
            .onChange(of: animate) { _, animate in
                if let index = storyTransitionModel.index(id) {
                    storyTransitionModel[index].isActive = true
                    storyTransitionModel[index].layerView = AnyView(layerView())
                    storyTransitionModel[index].sourceCornerRadius = sourceCornerRadius
                    storyTransitionModel[index].destinationCornerRadius = destinationCornerRadius
                    storyTransitionModel[index].zIndex = zIndex
                    storyTransitionModel[index].completion = completion
                    
                    if animate {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0.0)) {
                                storyTransitionModel[index].animateView = true
                            } completion: {
                                storyTransitionModel[index].hideView = true
                                storyTransitionModel[index].completion(true)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            storyTransitionModel[index].hideView = false
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0.0)) {
                                storyTransitionModel[index].animateView = false
                            } completion: {
                                storyTransitionModel[index].isActive = false
                                storyTransitionModel[index].layerView = nil
                                storyTransitionModel[index].sourceCornerRadius = 0.0
                                storyTransitionModel[index].destinationCornerRadius = 0.0
                                storyTransitionModel[index].sourceAnchor = nil
                                storyTransitionModel[index].destinationAnchor = nil
                                storyTransitionModel[index].zIndex = 0.0
                                storyTransitionModel[index].completion(false)
                            }
                        }
                    }
                }
            }
    }
}


struct SourceAnchorKey: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [String: Anchor<CGRect>]()
    
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()){$1}
    }
}

struct DestinationAnchorKey: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [String: Anchor<CGRect>]()
    
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()){$1}
    }
}

struct SourceView<Content: View>: View {
    
    let id: String
    let content: () -> Content
    
    init(id: String, content: @escaping () -> Content) {
        self.id = id
        self.content = content
    }
    
    @Environment(StoryTransitionModel.self) private var storyTransitionModel
    
    var body: some View {
        content()
            .opacity(opacity)
            .anchorPreference(key: SourceAnchorKey.self, value: .bounds) {
                if let index = storyTransitionModel.index(id), storyTransitionModel[index].isActive {
                    return [id: $0]
                }
                return [:]
            }
            .onPreferenceChange(SourceAnchorKey.self) { value in
                if let index = storyTransitionModel.index(id), storyTransitionModel[index].isActive, storyTransitionModel[index].sourceAnchor.isNil  {
                    storyTransitionModel[index].sourceAnchor = value[id]
                }
            }
    }
    
    var opacity: CGFloat {
        guard let index = storyTransitionModel.index(id) else { return 1.0 }
        return storyTransitionModel[index].destinationAnchor.isNil ? 1.0 : 0.0
    }
}

struct DestinationView<Content: View>: View {
    
    let id: String
    let content: () -> Content
    
    init(id: String, content: @escaping () -> Content) {
        self.id = id
        self.content = content
    }
    
    @Environment(StoryTransitionModel.self) private var storyTransitionModel
    
    var body: some View {
        content()
            .opacity(opacity)
            .anchorPreference(key: DestinationAnchorKey.self, value: .bounds) {
                if let index = storyTransitionModel.index(id), storyTransitionModel[index].isActive {
                    return [id: $0]
                }
                return [:]
            }
            .onPreferenceChange(DestinationAnchorKey.self) { value in
                if let index = storyTransitionModel.index(id), storyTransitionModel[index].isActive, !storyTransitionModel[index].hideView  {
                    storyTransitionModel[index].destinationAnchor = value[id]
                }
            }
    }
    
    var opacity: CGFloat {
        guard let index = storyTransitionModel.index(id) else { return 1.0 }
        return storyTransitionModel[index].isActive ? (storyTransitionModel[index].hideView ? 1 : 0) : 1
    }
}

struct StoryTransitionView: View {
    
    @Environment(StoryTransitionModel.self) private var transitionModel
        
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(transitionModel.items) { item in
                    if let sAnchor = item.sourceAnchor,
                       let dAnchor = item.destinationAnchor,
                       let layerView = item.layerView,
                        !item.hideView {
                        
                        let sRect = proxy[sAnchor]
                        let dRect = proxy[dAnchor]
                        let animateView = item.animateView
                        
                        let viewFrame = animateView ? dRect : sRect
                        let viewSize = animateView ? dRect.size : sRect.size
                        let viewCornerRadius = animateView ? item.sourceCornerRadius : item.destinationCornerRadius
                        
                        layerView
                            .frame(width: viewSize.width, height: viewSize.height)
                            .clipShape(.rect(cornerRadius: viewCornerRadius))
                            .offset(x: viewFrame.minX, y: viewFrame.minY)
                            .transition(.identity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .zIndex(item.zIndex)
                    }
                }
            }
        }
    }
}

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return view == rootViewController?.view ? nil : view
    }
}
