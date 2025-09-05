import SwiftUI
import AVKit

//struct FullscreenVideoOverlay: View {
//    var viewModel: VideoOverlayViewModel = .shared
//    
//    var body: some View {
//        if viewModel.isPresented, let player = viewModel.player {
//            VideoPlayer(player: player)
//                .ignoresSafeArea()
//                .gesture(
//                    DragGesture(minimumDistance: 30)
//                        .onEnded { value in
//                            if value.translation.height > 70 {
//                                viewModel.dismiss()
//                            }
//                        }
//                )
//        }
//    }
//}


struct FullscreenVideoOverlay: View {
    @Environment(\.videoNS) private var videoNS
    @Namespace private var fallbackNS
    
    var viewModel: VideoOverlayViewModel = .shared
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        if viewModel.isPresented, let player = viewModel.player {
            ZStack {
                // Fixed black background
                Color.black
                    .ignoresSafeArea()
                
                // VideoPlayer with gesture overlay
                VideoPlayer(player: player)
                    .matchedGeometryEffect(id: viewModel.currentVideoURL ?? "videoPlayer", in: videoNS ?? fallbackNS)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 15)
                            .onChanged { value in
                                isDragging = true
                                // Only allow downward dragging
                                if value.translation.height > 0 {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                
                                if value.translation.height > 70 {
                                    dismissVideo()
                                } else {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    
                .offset(dragOffset)
            }
            .onChange(of: viewModel.isPresented) { oldValue, newValue in
                if !newValue {
                    dragOffset = .zero
                }
            }
            #if os(macOS)
            .toolbarVisibility(.hidden, for: .windowToolbar)
            .overlay(alignment: .topLeading) {
                Button(role: .close) {
                    dismissVideo()
                }
                .keyboardShortcut(.cancelAction)
                .controlSize(.extraLarge)
                .labelStyle(.iconOnly)
                .padding(20)
            }
            #endif
        }
    }
    
    private func dismissVideo() {
        withAnimation(.easeInOut(duration: 0.4)) {
            dragOffset = .zero
            viewModel.dismiss()
        }
    }
}
