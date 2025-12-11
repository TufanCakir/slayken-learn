import MetalKit
import SwiftUI

struct MetalView: UIViewRepresentable {

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        view.backgroundColor = .clear
        view.preferredFramesPerSecond = 120
        view.framebufferOnly = false

        // Renderer installieren
        context.coordinator.renderer = Renderer(metalKitView: view)
        view.delegate = context.coordinator.renderer

        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var renderer: Renderer?
    }
}
