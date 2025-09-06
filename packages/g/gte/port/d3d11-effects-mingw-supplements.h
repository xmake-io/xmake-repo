#pragma once

typedef enum D3D11_SHADER_VERSION_TYPE
{
    D3D11_SHVER_PIXEL_SHADER    = 0,
    D3D11_SHVER_VERTEX_SHADER   = 1,
    D3D11_SHVER_GEOMETRY_SHADER = 2,

    // D3D11 Shaders
    D3D11_SHVER_HULL_SHADER     = 3,
    D3D11_SHVER_DOMAIN_SHADER   = 4,
    D3D11_SHVER_COMPUTE_SHADER  = 5,
} D3D11_SHADER_VERSION_TYPE;

#define D3D11_SHVER_GET_TYPE(_Version) \
    (((_Version) >> 16) & 0xffff)

#define D3D11_SHVER_GET_MAJOR(_Version) \
    (((_Version) >> 4) & 0xf)

#define D3D11_SHVER_GET_MINOR(_Version) \
    (((_Version) >> 0) & 0xf)
