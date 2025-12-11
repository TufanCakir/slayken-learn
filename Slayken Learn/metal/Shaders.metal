#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 projectionMatrix;
    float4x4 modelViewMatrix;
};

enum BufferIndex {
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2
};

enum VertexAttribute {
    VertexAttributePosition = 0,
    VertexAttributeTexcoord = 1
};

enum TextureIndex {
    TextureIndexColor = 0
};

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]],
                               constant Uniforms& uniforms [[buffer(BufferIndexUniforms)]])
{
    VertexOut out;
    float4 pos = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * pos;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<half> ice_realm [[texture(TextureIndexColor)]])
{
    constexpr sampler s(mag_filter::linear, min_filter::linear);
    half4 c = ice_realm.sample(s, in.texCoord);
    return float4(c);
}
