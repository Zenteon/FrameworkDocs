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
	Zenteon: Framework Hello World
	
	Discord: https://discord.gg/PpbcqJJs6h
	Patreon: https://patreon.com/Zenteon

*/
//========================================================================
#include "ReShade.fxh"
#include "FrameworkResources.fxh"

uniform int VIEW <
		ui_type = "combo";
		ui_label = "View";
		ui_items = "zfw::getBackBuffer()\0"
					"zfw::getDepth()\0"
					"zfw::getNormal()\0"
					"zfw::uvToView(uv)\0";
	> = 2;

float3 BlendPS(float4 vpos : SV_Position, float2 uv : TEXCOORD0) : SV_Target
{
	if(VIEW == 0) return zfw::getBackBuffer(uv);
	if(VIEW == 1) return zfw::getDepth(uv);
	if(VIEW == 2) return 0.5 + 0.5 * zfw::getNormal(uv);
	if(VIEW == 3) return 0.5 + 0.5 * zfw::uvToView(uv) / (abs(zfw::uvToView(uv)) + 10.0);
	
	return 0.0;
}

technique zfwHelloWorld <
		ui_label = "Framework: Hello World";
		    ui_tooltip =        
		        "Test of Zenteon: Framework functions";
		>	
	{
		pass {	VertexShader = PostProcessVS; PixelShader = BlendPS; }
	}
