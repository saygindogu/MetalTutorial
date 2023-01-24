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
    var pipelineState: MTLRenderPipelineState?
    let indices: Array<UInt16>
    var indexBuffer: MTLBuffer?
    var vertexBuffer: MTLBuffer?
    
    struct Constants {
        var animateBy: Float = 0.0
    }
    
    var constants = Constants()
    
    var time: Float = 0.0
    
    init(_ parent: ContentView){
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice(){
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        self.indices = [
            0,1,2,
            2,3,0
        ]
        super.init()
        pipelineState = buildPipelineState(device: metalDevice)
        buildModel()
        
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
    
    
    private func buildModel(){
        let vertices = [
            Vertex(position: [0,0], color: [1,0,0,1]), // V0
            Vertex(position: [0,1], color: [0,0,1,1]), // V1
            Vertex(position: [1,1], color: [0,1,0,1]), // V2
            Vertex(position: [1,0], color: [0,0,1,1]), // V3
        ]
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        indexBuffer = metalDevice.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])!
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        time += 1.0 / Float(view.preferredFramesPerSecond)
        
        let animateBy = abs(sin(time)/2 + 0.5)
        constants.animateBy = animateBy
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0,0.5,0.5,1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState!)
        
        renderEncoder?.setVertexBuffer(vertexBuffer!, offset: 0, index: 0)
        renderEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        renderEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer!, indexBufferOffset: 0)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
