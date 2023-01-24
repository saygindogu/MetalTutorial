//
//  Shaders.metal
//  MetalTutorialPlayout
//
//  Created by Saygın Doğu on 22.01.2023.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex Fragment vertex_shader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]){
    Vertex input = vertexArray[vid];
    
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    output.color = input.color;
    
    return output;
}

fragment float4 fragment_shader(Fragment input [[stage_in]]){
    return input.color;
}
