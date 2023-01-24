//
//  Renderer.swift
//  MetalTutorialPlayout
//
//  Created by Saygın Doğu on 22.01.2023.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: ContentView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    init(_ parent: ContentView){
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice(){
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        pipelineState = nil
        super.init()
        
        pipelineState = buildPipelineState(device: metalDevice)
        
    }
    
    private func buildPipelineState(device: MTLDevice) -> MTLRenderPipelineState{
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_shader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_shader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            return pipelineState
        }
        catch {
            fatalError()
        }
        
    }
    
    
    private func buildModel() -> MTLBuffer {
        let vertices = [
            Vertex(position: [0,0], color: [1,0,0,1]),
            Vertex(position: [1,1], color: [0,1,0,1]),
            Vertex(position: [0,1], color: [0,0,1,1]),
        ]
        return metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
    }
    
    private func buildModel2() -> MTLBuffer {
        let vertices = [
            Vertex(position: [0,0], color: [1,0,0,1]),
            Vertex(position: [1,1], color: [0,1,0,1]),
            Vertex(position: [1,0], color: [0,0,1,1]),
        ]
        return metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
    }
    
    
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0,0.5,0.5,1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        renderEncoder?.setVertexBuffer( buildModel(), offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder?.setVertexBuffer( buildModel2(), offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
       
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
