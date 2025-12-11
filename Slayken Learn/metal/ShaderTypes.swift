//
//  ShaderTypes.swift
//  Slayken Spirit
//
//  Created by Tufan Cakir on 01.12.25.
//

import simd

enum BufferIndex: Int {
    case meshPositions = 0
    case meshGenerics = 1
    case uniforms = 2
}

enum VertexAttribute: Int {
    case position = 0
    case texcoord = 1
}

enum TextureIndex: Int {
    case color = 0
}

struct Uniforms {
    var projectionMatrix: matrix_float4x4
    var modelViewMatrix: matrix_float4x4
}
