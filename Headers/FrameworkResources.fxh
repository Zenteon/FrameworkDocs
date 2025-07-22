//========================================================================
/*
	Copyright © Daniel Oren-Ibarra - 2025
	All Rights Reserved.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE,ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	
	
	======================================================================	
	Zenteon: Framework Resources
	
	Discord: https://discord.gg/PpbcqJJs6h
	Patreon: https://patreon.com/Zenteon

*/
//========================================================================

#pragma once

#define RES float2(BUFFER_WIDTH, BUFFER_HEIGHT)
#define FARPLANE RESHADE_DEPTH_LINEARIZATION_FAR_PLANE
#define IASPECT_RATIO float2(1.0, RES.x / RES.y)
#define WRAPMODE(WTYPE) AddressU = WTYPE; AddressV = WTYPE; AddressW = WTYPE
#define FILTER(FTYPE) MagFilter = FTYPE; MinFilter = FTYPE; MipFilter = FTYPE
#define DIV_RND_UP(a, b) ((int(a)+int(b)-1)/int(b))
#define DIVRES(DIVRES_RIV) Width = DIV_RND_UP(RES.x, DIVRES_RIV); Height = DIV_RND_UP(RES.y, DIVRES_RIV)

namespace zfw {
	texture2D tNormal { DIVRES(1); Format = RG16; MipLevels = 7; };
	sampler2D sNormal { Texture = tNormal; FILTER(POINT); };
	texture2D tAlbedo { DIVRES(1); Format = RGBA8; };
	sampler2D sAlbedo { Texture = tAlbedo; };
	texture2D tRoughness { DIVRES(1); Format = R8; };
	sampler2D sRoughness { Texture = tRoughness; };
	//store disocclusion in b channel
	texture2D tVelocity { DIVRES(1); Format = RGBA16F; };
	sampler2D sVelocity { Texture = tVelocity; FILTER(POINT); };
	texture2D tLowNormal { DIVRES(4); Format = RG8; MipLevels = 7; };
	sampler2D sLowNormal { Texture = tLowNormal; MagFilter = POINT; };
	texture2D tLowDepth { DIVRES(4); Format = R16; MipLevels = 7; };
	sampler2D sLowDepth { Texture = tLowDepth; };
	
	//===================================================================================
	//Projections
	//===================================================================================

	float getDepth(float2 xy)
	{
		return ReShade::GetLinearizedDepth(xy);
	}
	
	
	#define FOV (1.0 * 0.0174533 * 70.0)
	#define fl rcp(tan(0.5 * FOV))
	
	float3 uvzToView(float3 xyz)
	{
		xyz.xy = (floor(xyz.xy*RES) + 0.5) / RES;
		float3 m = float3(fl / IASPECT_RATIO, 1.0);
		float z = xyz.z;
		xyz = float3(2*xyz.xy-1,1.0);
		return (z * FARPLANE + 1.0) * xyz*m;
	}

	float3 uvzToView(float2 xy, float z)
	{
		xy = (floor(xy*RES) + 0.5) / RES;
		float3 m = float3(fl / IASPECT_RATIO, 1.0);
		float3 xyz = float3(2*xy-1,1.0);
		return (z * FARPLANE + 1.0) * xyz*m;
	}
	
	float3 uvToView(float2 xy)
	{
		xy = (floor(xy*RES) + 0.5) / RES;
		float z = ReShade::GetLinearizedDepth(xy);
		float3 m = float3(fl / IASPECT_RATIO, 1.0);
		float3 xyz = float3(2*xy-1,1.0);
		return (z * FARPLANE + 1.0) * xyz*m;
	}
	
	float3 viewToUv(float3 xyz)
	{
		float3 m = float3(fl / IASPECT_RATIO, FARPLANE);
		xyz.xy /= m.xy * xyz.z;
		return float3(0.5 + 0.5 * xyz.xy, (xyz.z - 1.0) / FARPLANE);
	}
	
	float3 UVtoOCT(float2 xy)
	{	
		float3 xyz = float3(2f * xy - 1f, 0.0);                
	
		float2 posAbs = abs(xyz.xy);
		xyz.z = 1.0 - (posAbs.x + posAbs.y);
	
		if(xyz.z < 0) {
	        xyz.xy = sign(xyz.xy) * (1.0 - posAbs.yx);
		}
		return xyz;
	}
	
	float2 OCTtoUV(float3 xyz) {
		float3 octsn = sign(xyz);
		
		float sd = dot(xyz, octsn);        
		float3 oct = xyz / sd;    
		
		if(oct.z < 0) {
			float3 posAbs = abs(oct);
			oct.xy = octsn.xy * (1.0 - posAbs.yx);
		}
			return 0.5 + 0.5 * oct.xy;
	}
	
	//===================================================================================
	//Encoding
	//===================================================================================
	
	float2 OctWrap(float2 v)
	{
	    return (1.0- abs(v.yx)) * (v.xy >= 0.0 ? 1.0 : -1.0);
	}
	 
	float2 NormalEncode(float3 n)
	{
		return OCTtoUV(-n);
	}
	 
	float3 NormalDecode(float2 n)
	{
		return normalize(-UVtoOCT(n));
	}
	
	//===================================================================================
	//Sampling
	//===================================================================================
	
	float3 getNormal(float2 xy)
	{
		float2 n = tex2Dlod(zfw::sNormal, float4(xy, 0, 0)).xy;
		return NormalDecode(n);	
	}
	
	float getRoughness(float2 xy)
	{
		return tex2Dlod(zfw::sRoughness, float4(xy,0,0)).x;
	}
	
	//dissoclusion in b
	float3 getVelocity(float2 xy)
	{
		return tex2Dlod(zfw::sVelocity, float4(xy,0,0)).xyz;
	}
	
	float3 sampleNormal(float2 xy, float l)
	{
		float2 n = tex2Dlod(zfw::sLowNormal, float4(xy, 0, l)).xy;
		return NormalDecode(n);	
	}
	
	float sampleDepth(float2 xy, float l)
	{
		return tex2Dlod(zfw::sLowDepth, float4(xy, 0, l)).x;
	}
	
	float3 getBackBuffer(float2 xy)
	{
		return tex2D(ReShade::BackBuffer, xy).rgb;
		//return tex2D(Zenteon::sTest, xy).rgb;
	}
	
	float3 getAlbedo(float2 xy)
	{
		return pow(tex2D(zfw::sAlbedo, xy).rgb, 2.2);
	}
	
	
	//===================================================================================
	//Functions
	//===================================================================================
	
	float getLuminance( float3 x)
	{
		return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
	}	
	
	float3 toneMap(float3 x, float whitepoint)
	{
		float HDR_RED = 1.0 + rcp(whitepoint);
		float l = dot(x, float3(0.2126, 0.7152,0.0722));
		x /= l + 0.0001;
		return pow(x * HDR_RED * l / (l + 1.0), rcp(2.2));
	}
	
	float3 toneMapInverse(float3 x, float whitepoint)
	{	
		x = pow(x,2.2);
		float HDR_RED = 1.0 + rcp(whitepoint);
		float l = dot(x, float3(0.2126, 0.7152,0.0722));
		x /= l + 0.0001;
		return  max(x * -l / (l - HDR_RED), 0.0000001);
	
	}

}

#undef RES
#undef FARPLANE
#undef IASPECT_RATIO
#undef WRAPMODE
#undef FILTER
#undef DIV_RND_UP
#undef DIVRES
