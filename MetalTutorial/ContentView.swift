//
//  ContentView.swift
//  MetalTutorial
//
//  Created by Saygın Doğu on 23.01.2023.
//

import SwiftUI
import MetalKit

struct ContentView: NSViewRepresentable {


    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<ContentView>) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
    }
    
    func updateNSView(_ uiView: MTKView, context: NSViewRepresentableContext<ContentView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
