# FrameworkDocs
Developer documentation for "Zenteon: Framework" ReShade reconstruction framework.

# NOTE: This page is a work in process
While the included .fhx header file(s) and assets are under the FRL license, the original shader still falls under the restrictions of the AGNYA License: https://github.com/nvb-uy/AGNYA-License.

**Dependencies:** Framework is currently dependent on the standard "ReShade.fxh", this dependency is planned to be removed in the future.

v0.1
# Buffers
In addition to the standard COLOR and DEPTH Buffers provided by the ReShade.fxh, framework generates a few additional buffers for shader usage.

**Full Resolution Buffers:**
1. ```zfw::tNormal``` - Octahedral encoded normal buffer, optionally processed with smoothing and texturing via Framework settings.
2. ```zfw::tAlbedo``` - Estimated albedo buffer.
3. ```zfw::tRoughness``` - Estimated roughness buffer.
4. ```zfw::tVelocity``` - 1:1 Motion vectors, with dissoclusion stored in the z channel.

**Reduced Resolution Buffers:**
1. ```zfw::tLowNormal``` - A quarter resolution octahedral encoded normal buffer, meant to save performance when distant sampling is required.
2. ```zfw::tLowDepth``` - A quarter resolution depth buffer, meant to save performance when distant sampling is required. Uses the max depth in each 4x4 block to prevent halos.

# Functions
In order to streamline development and allow ease of access to the generated buffers, Framework provides some additional functions.

**Projections**
```float zfw::getDepth(float2 uv)``` Returns the linearized depth value, identical to ```ReShade::GetLinearizedDepth```, just faster to type.
```float3 zfw::uvzToView(float3 uvz)``` Projects uvz coordinates to viewspace.
```float3 zfw::uvToView(float2 xy)``` Projects uv coordinates to viewspace, automatically grabbing depth from the specified uv coordinates.
```float3 zfw::viewToUv(float3 xyz)``` Projects viewspace coordinates to uvz space.

**Sampling Functions**
```float3 zfw::getNormal(float2 uv)``` Samples and decodes the full resolution normal value at the specified uv coordinates.
```float zfw::getRoughness(float2 uv)``` Returns the roughness buffer value at the specified uv coordinates.
```float3 zfw::getVelocity(float2 uv)``` Returns the velocity buffer value at the specified uv coordinates. Sample confidence (1.0 for valid samples, 0.0 for invalid) is stored in the z channel for sample rejection.
```float3 zfw::getBackBuffer(float2 xy)``` Returns the rgb values of the COLOR buffer at the specified uv coordinates.
```float3 zfw::getAlbedo(float2 xy)``` Returns the estimated albedo value at the specified uv coordinates.


```float3 zfw::sampleNormal(float2 uv, float mip)``` Samples and decodes the quarter resolution normal value at the specified uv coordinates and miplevel.
```float zfw::sampleDepth(float2 uv, float mip)``` Samples the quarter resolution depth value at the specified uv coordinates and miplevel. Note that this currently produces averaged mips past the first level, exercise caution to avoid haloing.

**Tonemapping**
The FrameworkResources.fxh also includes a luminance preserving tonemapper and inverse tonemapper that prevents oversaturation significantly. Note that these are meant to be used in tandem: using different operators for tonemapping and inverting is not recommended.
```float3 zfw::toneMap(float3 x, float whitepoint)``` Tonemaps the input color with the specified whitepoint.
```float3 toneMapInverse(float3 x, float whitepoint)``` Inverse tonemaps the input color with the specified whitepoint.

**Internal functions**
Framework also has a few functions used internally, that while they aren't specifically intended for the user, may still be of use.
```float3 zfw::UVtoOCT(float2 uv)``` Converts from uv to octahedral coordinates.
```float2 zfw::OCTtoUV(float3 xyz)``` Converts from octahedral coordinated to uv.
```float2 zfw::NormalEncode(float3 n)``` Compresses normals to octahedral.
```float3 zfw::NormalDecode(float2 n)``` Decompresses octahedral normals.
```float zfw::getLuminance(float3 x)``` Returns the luminance of the input (linear) color.
