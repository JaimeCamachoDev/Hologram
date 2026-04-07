// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hologram Shader IA"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HDR]_MainColor("Main Color", Color) = (0.620945,1.420074,3.953349,0.05098039)
		_AlphaHeight("Alpha Height", Float) = 0.76
		_MainTexture("Main Texture", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 0
		_NormalAffect("NormalAffect", Range( 0 , 1)) = 0
		[Header(FRESNEL)][Header(_)]_FresnelScale("Fresnel Scale", Float) = 1
		_FresnelPower("Fresnel Power", Float) = 2
		_FresnelAlphaScale("Fresnel Alpha Scale", Float) = 1
		_FresnelAlphaPower("Fresnel Alpha Power", Float) = 2
		[Header(LINES)][Header(_)][NoScaleOffset]_Line3("Line 1", 2D) = "white" {}
		_Line1Speed1("Line 1 Speed", Float) = -3.57
		_Line1Frequency1("Line 1 Frequency", Float) = 100
		_Line1Hardness1("Line 1 Hardness", Float) = 1.45
		_Line1InvertedThickness1("Line 1 Inverted Thickness", Range( 0 , 1)) = 0
		_Line1Alpha1("Line 1 Alpha", Float) = 0.15
		_Line2Speed("Line 2 Speed", Float) = -1
		_Line2Frequency("Line 2 Frequency", Float) = -1
		_Line2Alpha("Line 2 Alpha", Float) = 0.1
		[Header(GRAIN)][Header(_)]_GrainAffect("Grain Affect", Range( 0 , 1)) = 1
		_GrainScale("Grain Scale", Int) = 1000
		[Header(GLITCH COLOR )][Header(_)]_GlitchColorAffect("Glitch Color Affect", Range( 0 , 1)) = 0.5
		[Header(GLITCH LINE 2)][Header(_)]_GlitchLine2Offset("Glitch Line 2 Offset", Vector) = (0.5,0,0,0)
		_RandomGlitchOffset("Random Glitch Offset", Vector) = (-0.5,0,0,0)
		_RandomGlitchAmount("Random Glitch Amount", Range( 0 , 1)) = 0.089
		_GlichSpeed("Glich Speed", Vector) = (1,-1,1,0)
		_RandomGlitchConstant("Random Glitch Constant", Range( 0 , 1)) = 0.4889122
		_RandomGlitchTiling("Random Glitch Tiling", Float) = 2.83
		_Voxelization("Voxelization", Float) = 100
		_VoxelizationAffect("Voxelization Affect", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//[HideInInspector][ToggleUI] _AddPrecomputedVelocity("Add Precomputed Velocity", Float) = 1
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Off
		AlphaToMask Off

		Stencil
		{
			Ref 255
			CompFront Always
			PassFront Keep
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		#pragma exclude_renderers xboxone xboxseries playstation ps4 ps5 switch // ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 170003


			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD2;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD3;
				#endif
				#if defined(LIGHTMAP_ON)
					float4 lightmapUVOrVertexSH : TEXCOORD4;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD5;
				#endif
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _MainTexture_ST;
			half4 _NormalMap_ST;
			half4 _MainColor;
			half3 _GlitchLine2Offset;
			half3 _RandomGlitchOffset;
			half3 _GlichSpeed;
			half _Line1Alpha1;
			half _Line1Hardness1;
			half _Line1InvertedThickness1;
			half _Line1Speed1;
			half _Line1Frequency1;
			half _GrainAffect;
			int _GrainScale;
			half _FresnelAlphaPower;
			half _FresnelAlphaScale;
			half _NormalScale;
			half _Line2Alpha;
			half _FresnelPower;
			half _FresnelScale;
			half _GlitchColorAffect;
			half _VoxelizationAffect;
			half _Voxelization;
			half _RandomGlitchAmount;
			half _RandomGlitchConstant;
			half _RandomGlitchTiling;
			half _Line2Speed;
			half _Line2Frequency;
			half _NormalAffect;
			half _AlphaHeight;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _NormalMap;
			sampler2D _MainTexture;
			sampler2D _Line3;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				half3 viewToObjDir94 = mul( UNITY_MATRIX_T_MV, float4( _GlitchLine2Offset, 0.0 ) ).xyz;
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				half mulTime685 = _TimeParameters.x * _Line2Speed;
				half Line_2734 = frac( ( ( ase_positionWS.y * _Line2Frequency ) + mulTime685 ) );
				half3 lineglitch491 = ( ( viewToObjDir94 / ase_objectScale ) * Line_2734 );
				half3 viewToObjDir122 = mul( UNITY_MATRIX_T_MV, float4( _RandomGlitchOffset, 0.0 ) ).xyz;
				half mulTime149 = _TimeParameters.x * _GlichSpeed.x;
				half mulTime155 = _TimeParameters.x * _GlichSpeed.y;
				half2 appendResult153 = (half2((ase_positionWS.y*_RandomGlitchTiling + mulTime149) , mulTime155));
				half simplePerlin2D186 = snoise( appendResult153 );
				simplePerlin2D186 = simplePerlin2D186*0.5 + 0.5;
				half mulTime761 = _TimeParameters.x * _GlichSpeed.z;
				half2 temp_cast_0 = (mulTime761).xx;
				half simplePerlin2D762 = snoise( temp_cast_0*7.18 );
				simplePerlin2D762 = simplePerlin2D762*0.5 + 0.5;
				half clampResult148 = clamp( (-1.0 + (( simplePerlin2D762 + _RandomGlitchConstant ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
				half temp_output_197_0 = ( (-1.0 + (simplePerlin2D186 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * clampResult148 );
				half simplePerlin2D188 = snoise( ( 20.0 * appendResult153 ) );
				simplePerlin2D188 = simplePerlin2D188*0.5 + 0.5;
				half clampResult192 = clamp( (-1.0 + (simplePerlin2D188 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
				half lerpResult199 = lerp( 0.0 , clampResult192 , 2.0);
				half3 randomglitch493 = ( ( viewToObjDir122 / ase_objectScale ) * ( temp_output_197_0 + ( temp_output_197_0 * lerpResult199 ) ) * _RandomGlitchAmount );
				half3 temp_output_512_0 = ( input.positionOS.xyz + ( lineglitch491 + randomglitch493 ) );
				half3 lerpResult517 = lerp( temp_output_512_0 , ( round( ( temp_output_512_0 * _Voxelization ) ) / _Voxelization ) , _VoxelizationAffect);
				half3 ModifiedVertexPosition519 = lerpResult517;
				
				half3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord6.xyz = ase_normalWS;
				float3 ase_tangentWS = TransformObjectToWorldDir( input.ase_tangent.xyz );
				output.ase_texcoord8.xyz = ase_tangentWS;
				float ase_tangentSign = input.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord9.xyz = ase_bitangentWS;
				
				output.ase_texcoord7.xy = input.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.w = 0;
				output.ase_texcoord7.zw = 0;
				output.ase_texcoord8.w = 0;
				output.ase_texcoord9.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ModifiedVertexPosition519;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						output.fogFactorAndVertexLight.x = ComputeFogFactor(vertexInput.positionCS.z);
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_tangent = input.ase_tangent;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				float3 WorldPosition = input.positionWS;
				float3 WorldViewDirection = GetWorldSpaceNormalizeViewDir( WorldPosition );
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				half mulTime165 = _TimeParameters.x * -15.0;
				half mulTime167 = _TimeParameters.x * -0.5;
				half2 appendResult168 = (half2((0.0*223.0 + ( (0) + mulTime165 )) , ( (0) + mulTime167 )));
				half simplePerlin2D176 = snoise( appendResult168 );
				simplePerlin2D176 = simplePerlin2D176*0.5 + 0.5;
				half clampResult175 = clamp( (-0.61 + (simplePerlin2D176 - 0.0) * (2.0 - -0.61) / (1.0 - 0.0)) , 0.0 , 1.0 );
				half lerpResult181 = lerp( 1.0 , clampResult175 , _GlitchColorAffect);
				half ColorGlitch689 = lerpResult181;
				half3 ase_normalWS = input.ase_texcoord6.xyz;
				half fresnelNdotV571 = dot( ase_normalWS, WorldViewDirection );
				half fresnelNode571 = ( 0.0 + _FresnelScale * pow( max( 1.0 - fresnelNdotV571 , 0.0001 ), _FresnelPower ) );
				float2 uv_NormalMap = input.ase_texcoord7.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				half3 unpack584 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
				unpack584.z = lerp( 1, unpack584.z, saturate(_NormalScale) );
				float3 ase_tangentWS = input.ase_texcoord8.xyz;
				float3 ase_bitangentWS = input.ase_texcoord9.xyz;
				float3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
				float3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
				float3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
				float3 ase_viewVectorTS =  tanToWorld0 * ( _WorldSpaceCameraPos.xyz - WorldPosition ).x + tanToWorld1 * ( _WorldSpaceCameraPos.xyz - WorldPosition ).y  + tanToWorld2 * ( _WorldSpaceCameraPos.xyz - WorldPosition ).z;
				float3 ase_viewDirTS = normalize( ase_viewVectorTS );
				half dotResult587 = dot( unpack584 , ase_viewDirTS );
				half lerpResult590 = lerp( 1.0 , (0.0 + (dotResult587 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , _NormalAffect);
				half NormalAffect594 = ( 1.0 - lerpResult590 );
				float2 uv_MainTexture = input.ase_texcoord7.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				half4 tex2DNode605 = tex2D( _MainTexture, uv_MainTexture );
				half3 maincolor232 = ( _MainColor.rgb * tex2DNode605.rgb );
				half fresnelNdotV569 = dot( ase_normalWS, WorldViewDirection );
				half fresnelNode569 = ( 0.0 + _FresnelAlphaScale * pow( max( 1.0 - fresnelNdotV569 , 0.0001 ), _FresnelAlphaPower ) );
				half clampResult577 = clamp( ( fresnelNode569 + NormalAffect594 ) , 0.0 , 1.0 );
				half3 fresnelcolor580 = ( ( fresnelNode571 + NormalAffect594 ) * maincolor232 * clampResult577 );
				half3 temp_cast_0 = _GrainScale;
				half mulTime273 = _TimeParameters.x * 10.0;
				half simplePerlin3D264 = snoise( (WorldPosition*temp_cast_0 + mulTime273) );
				simplePerlin3D264 = simplePerlin3D264*0.5 + 0.5;
				half lerpResult278 = lerp( -1.0 , 1.0 , simplePerlin3D264);
				half lerpResult269 = lerp( 0.0 , lerpResult278 , _GrainAffect);
				half grain268 = lerpResult269;
				half mulTime3_g178 = _TimeParameters.x * _Line1Speed1;
				half2 temp_cast_1 = ((WorldPosition.y*_Line1Frequency1 + ( mulTime3_g178 + 0.0 ))).xx;
				half clampResult42_g178 = clamp( ( ( tex2D( _Line3, temp_cast_1 ).r - _Line1InvertedThickness1 ) * _Line1Hardness1 ) , 0.0 , 1.0 );
				half temp_output_715_0 = clampResult42_g178;
				half temp_output_638_0 = ( temp_output_715_0 * _Line1Alpha1 );
				half4 appendResult683 = (half4(0.0 , 0.0 , 0.0 , temp_output_638_0));
				half mulTime685 = _TimeParameters.x * _Line2Speed;
				half Line_2734 = frac( ( ( WorldPosition.y * _Line2Frequency ) + mulTime685 ) );
				half4 appendResult644 = (half4(( (( maincolor232 * temp_output_715_0 )).xyz * (( maincolor232 * Line_2734 )).xyz ) , ( temp_output_638_0 * ( Line_2734 * _Line2Alpha ) )));
				half4 line_color650 = ( appendResult683 + appendResult644 );
				half clampResult768 = clamp( ( WorldPosition.y + _AlphaHeight ) , 0.0 , 1.0 );
				half lerpResult400 = lerp( 0.0 , tex2DNode605.a , clampResult768);
				half alphamask402 = lerpResult400;
				half fresnelalpha579 = clampResult577;
				half clampResult677 = clamp( ( fresnelalpha579 + (line_color650).w ) , 0.0 , 1.0 );
				half4 appendResult679 = (half4(( ColorGlitch689 * ( fresnelcolor580 + grain268 + maincolor232 + (line_color650).xyz ) ) , ( alphamask402 * clampResult677 )));
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = appendResult679.xyz;
				float Alpha = (appendResult679).w;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "MotionVectors"
			Tags { "LightMode"="MotionVectors" }

			ColorMask RG

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 170003


			#pragma vertex vert
			#pragma fragment frag

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
		    #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
			#endif

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MotionVectorsCommon.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 positionOld : TEXCOORD4;
				#if _ADD_PRECOMPUTED_VELOCITY
					float3 alembicMotionVector : TEXCOORD5;
				#endif
				half3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 positionCSNoJitter : TEXCOORD0;
				float4 previousPositionCSNoJitter : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _MainTexture_ST;
			half4 _NormalMap_ST;
			half4 _MainColor;
			half3 _GlitchLine2Offset;
			half3 _RandomGlitchOffset;
			half3 _GlichSpeed;
			half _Line1Alpha1;
			half _Line1Hardness1;
			half _Line1InvertedThickness1;
			half _Line1Speed1;
			half _Line1Frequency1;
			half _GrainAffect;
			int _GrainScale;
			half _FresnelAlphaPower;
			half _FresnelAlphaScale;
			half _NormalScale;
			half _Line2Alpha;
			half _FresnelPower;
			half _FresnelScale;
			half _GlitchColorAffect;
			half _VoxelizationAffect;
			half _Voxelization;
			half _RandomGlitchAmount;
			half _RandomGlitchConstant;
			half _RandomGlitchTiling;
			half _Line2Speed;
			half _Line2Frequency;
			half _NormalAffect;
			half _AlphaHeight;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _NormalMap;
			sampler2D _MainTexture;
			sampler2D _Line3;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				half3 viewToObjDir94 = mul( UNITY_MATRIX_T_MV, float4( _GlitchLine2Offset, 0.0 ) ).xyz;
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				half mulTime685 = _TimeParameters.x * _Line2Speed;
				half Line_2734 = frac( ( ( ase_positionWS.y * _Line2Frequency ) + mulTime685 ) );
				half3 lineglitch491 = ( ( viewToObjDir94 / ase_objectScale ) * Line_2734 );
				half3 viewToObjDir122 = mul( UNITY_MATRIX_T_MV, float4( _RandomGlitchOffset, 0.0 ) ).xyz;
				half mulTime149 = _TimeParameters.x * _GlichSpeed.x;
				half mulTime155 = _TimeParameters.x * _GlichSpeed.y;
				half2 appendResult153 = (half2((ase_positionWS.y*_RandomGlitchTiling + mulTime149) , mulTime155));
				half simplePerlin2D186 = snoise( appendResult153 );
				simplePerlin2D186 = simplePerlin2D186*0.5 + 0.5;
				half mulTime761 = _TimeParameters.x * _GlichSpeed.z;
				half2 temp_cast_0 = (mulTime761).xx;
				half simplePerlin2D762 = snoise( temp_cast_0*7.18 );
				simplePerlin2D762 = simplePerlin2D762*0.5 + 0.5;
				half clampResult148 = clamp( (-1.0 + (( simplePerlin2D762 + _RandomGlitchConstant ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
				half temp_output_197_0 = ( (-1.0 + (simplePerlin2D186 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * clampResult148 );
				half simplePerlin2D188 = snoise( ( 20.0 * appendResult153 ) );
				simplePerlin2D188 = simplePerlin2D188*0.5 + 0.5;
				half clampResult192 = clamp( (-1.0 + (simplePerlin2D188 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
				half lerpResult199 = lerp( 0.0 , clampResult192 , 2.0);
				half3 randomglitch493 = ( ( viewToObjDir122 / ase_objectScale ) * ( temp_output_197_0 + ( temp_output_197_0 * lerpResult199 ) ) * _RandomGlitchAmount );
				half3 temp_output_512_0 = ( input.positionOS.xyz + ( lineglitch491 + randomglitch493 ) );
				half3 lerpResult517 = lerp( temp_output_512_0 , ( round( ( temp_output_512_0 * _Voxelization ) ) / _Voxelization ) , _VoxelizationAffect);
				half3 ModifiedVertexPosition519 = lerpResult517;
				
				output.ase_texcoord2.xyz = ase_positionWS;
				half3 ase_normalWS = TransformObjectToWorldNormal( input.ase_normal );
				output.ase_texcoord3.xyz = ase_normalWS;
				float3 ase_tangentWS = TransformObjectToWorldDir( input.ase_tangent.xyz );
				output.ase_texcoord5.xyz = ase_tangentWS;
				float ase_tangentSign = input.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord6.xyz = ase_bitangentWS;
				
				output.ase_texcoord4.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
				output.ase_texcoord4.zw = 0;
				output.ase_texcoord5.w = 0;
				output.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ModifiedVertexPosition519;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				// Jittered. Match the frame.
				output.positionCS = vertexInput.positionCS;
				output.positionCSNoJitter = mul( _NonJitteredViewProjMatrix, mul( UNITY_MATRIX_M, input.positionOS ) );

				float4 prevPos = ( unity_MotionVectorsParams.x == 1 ) ? float4( input.positionOld, 1 ) : input.positionOS;

				#if _ADD_PRECOMPUTED_VELOCITY
					prevPos = prevPos - float4(input.alembicMotionVector, 0);
				#endif

				output.previousPositionCSNoJitter = mul( _PrevViewProjMatrix, mul( UNITY_PREV_MATRIX_M, prevPos ) );

				return output;
			}

			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}

			half4 frag(	PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				half mulTime165 = _TimeParameters.x * -15.0;
				half mulTime167 = _TimeParameters.x * -0.5;
				half2 appendResult168 = (half2((0.0*223.0 + ( (0) + mulTime165 )) , ( (0) + mulTime167 )));
				half simplePerlin2D176 = snoise( appendResult168 );
				simplePerlin2D176 = simplePerlin2D176*0.5 + 0.5;
				half clampResult175 = clamp( (-0.61 + (simplePerlin2D176 - 0.0) * (2.0 - -0.61) / (1.0 - 0.0)) , 0.0 , 1.0 );
				half lerpResult181 = lerp( 1.0 , clampResult175 , _GlitchColorAffect);
				half ColorGlitch689 = lerpResult181;
				float3 ase_positionWS = input.ase_texcoord2.xyz;
				half3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - ase_positionWS );
				half3 ase_viewDirWS = normalize( ase_viewVectorWS );
				half3 ase_normalWS = input.ase_texcoord3.xyz;
				half fresnelNdotV571 = dot( ase_normalWS, ase_viewDirWS );
				half fresnelNode571 = ( 0.0 + _FresnelScale * pow( max( 1.0 - fresnelNdotV571 , 0.0001 ), _FresnelPower ) );
				float2 uv_NormalMap = input.ase_texcoord4.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				half3 unpack584 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
				unpack584.z = lerp( 1, unpack584.z, saturate(_NormalScale) );
				float3 ase_tangentWS = input.ase_texcoord5.xyz;
				float3 ase_bitangentWS = input.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
				float3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
				float3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
				float3 ase_viewVectorTS =  tanToWorld0 * ( _WorldSpaceCameraPos.xyz - ase_positionWS ).x + tanToWorld1 * ( _WorldSpaceCameraPos.xyz - ase_positionWS ).y  + tanToWorld2 * ( _WorldSpaceCameraPos.xyz - ase_positionWS ).z;
				float3 ase_viewDirTS = normalize( ase_viewVectorTS );
				half dotResult587 = dot( unpack584 , ase_viewDirTS );
				half lerpResult590 = lerp( 1.0 , (0.0 + (dotResult587 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , _NormalAffect);
				half NormalAffect594 = ( 1.0 - lerpResult590 );
				float2 uv_MainTexture = input.ase_texcoord4.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				half4 tex2DNode605 = tex2D( _MainTexture, uv_MainTexture );
				half3 maincolor232 = ( _MainColor.rgb * tex2DNode605.rgb );
				half fresnelNdotV569 = dot( ase_normalWS, ase_viewDirWS );
				half fresnelNode569 = ( 0.0 + _FresnelAlphaScale * pow( max( 1.0 - fresnelNdotV569 , 0.0001 ), _FresnelAlphaPower ) );
				half clampResult577 = clamp( ( fresnelNode569 + NormalAffect594 ) , 0.0 , 1.0 );
				half3 fresnelcolor580 = ( ( fresnelNode571 + NormalAffect594 ) * maincolor232 * clampResult577 );
				half3 temp_cast_0 = _GrainScale;
				half mulTime273 = _TimeParameters.x * 10.0;
				half simplePerlin3D264 = snoise( (ase_positionWS*temp_cast_0 + mulTime273) );
				simplePerlin3D264 = simplePerlin3D264*0.5 + 0.5;
				half lerpResult278 = lerp( -1.0 , 1.0 , simplePerlin3D264);
				half lerpResult269 = lerp( 0.0 , lerpResult278 , _GrainAffect);
				half grain268 = lerpResult269;
				half mulTime3_g178 = _TimeParameters.x * _Line1Speed1;
				half2 temp_cast_1 = ((ase_positionWS.y*_Line1Frequency1 + ( mulTime3_g178 + 0.0 ))).xx;
				half clampResult42_g178 = clamp( ( ( tex2D( _Line3, temp_cast_1 ).r - _Line1InvertedThickness1 ) * _Line1Hardness1 ) , 0.0 , 1.0 );
				half temp_output_715_0 = clampResult42_g178;
				half temp_output_638_0 = ( temp_output_715_0 * _Line1Alpha1 );
				half4 appendResult683 = (half4(0.0 , 0.0 , 0.0 , temp_output_638_0));
				half mulTime685 = _TimeParameters.x * _Line2Speed;
				half Line_2734 = frac( ( ( ase_positionWS.y * _Line2Frequency ) + mulTime685 ) );
				half4 appendResult644 = (half4(( (( maincolor232 * temp_output_715_0 )).xyz * (( maincolor232 * Line_2734 )).xyz ) , ( temp_output_638_0 * ( Line_2734 * _Line2Alpha ) )));
				half4 line_color650 = ( appendResult683 + appendResult644 );
				half clampResult768 = clamp( ( ase_positionWS.y + _AlphaHeight ) , 0.0 , 1.0 );
				half lerpResult400 = lerp( 0.0 , tex2DNode605.a , clampResult768);
				half alphamask402 = lerpResult400;
				half fresnelalpha579 = clampResult577;
				half clampResult677 = clamp( ( fresnelalpha579 + (line_color650).w ) , 0.0 , 1.0 );
				half4 appendResult679 = (half4(( ColorGlitch689 * ( fresnelcolor580 + grain268 + maincolor232 + (line_color650).xyz ) ) , ( alphamask402 * clampResult677 )));
				

				float Alpha = (appendResult679).w;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( input.positionCS );
				#endif

				return float4( CalcNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 0, 0 );
			}
			ENDHLSL
		}
		
	}
	
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;310;-736,-480;Inherit;False;3126.44;1370.566;Random Glitch;24;493;123;506;505;122;121;128;196;201;197;198;199;192;148;124;191;147;129;202;127;126;210;211;209;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;209;-704,-400;Inherit;False;1227.303;532.5337;Main Glitch Cycle;8;186;153;155;152;760;151;149;769;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;769;-640,-32;Inherit;False;Property;_GlichSpeed;Glich Speed;25;0;Create;True;0;0;0;False;0;False;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;149;-400,-96;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;760;-416,-320;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;151;-432,-176;Inherit;False;Property;_RandomGlitchTiling;Random Glitch Tiling;27;0;Create;True;0;0;0;False;0;False;2.83;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;152;-176,-240;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;155;-128,32;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;735;-736,-1344;Inherit;False;1093;342.95;Line 2 Main;8;687;613;737;734;688;686;685;738;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;211;-256,160;Inherit;False;695.8618;324;Random Glitch;4;225;226;762;761;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;112,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;210;-256,528;Inherit;False;726.2931;286.3221;Small Glitch lines;4;188;193;194;771;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;613;-672,-1072;Inherit;False;Property;_Line2Speed;Line 2 Speed;16;0;Create;True;0;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;738;-704,-1152;Inherit;False;Property;_Line2Frequency;Line 2 Frequency;17;0;Create;True;0;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;687;-672,-1296;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;761;-224,256;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;771;-256,608;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-176,576;Inherit;False;Constant;_Float2;Float 2;34;0;Create;True;0;0;0;False;0;False;20;20.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;685;-496,-1072;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;737;-464,-1248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;549;-720,-4032;Inherit;False;670.612;448.8643;Color;4;232;604;605;231;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;562;-720,-5280;Inherit;False;1521.172;436.0327;Normal Map;9;594;591;590;589;588;587;586;585;584;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;762;-32,256;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;7.18;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-96,368;Inherit;False;Property;_RandomGlitchConstant;Random Glitch Constant;26;0;Create;True;0;0;0;False;0;False;0.4889122;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-16,576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;686;-288,-1216;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;610;-736,-3264;Inherit;False;1923.354;1230.809;Lines;8;650;684;683;644;639;640;611;612;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;605;-704,-3776;Inherit;True;Property;_MainTexture;Main Texture;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;585;-656,-5184;Inherit;False;Property;_NormalScale;NormalScale;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;231;-704,-3984;Inherit;False;Property;_MainColor;Main Color;0;1;[HDR];Create;True;0;0;0;False;0;False;0.620945,1.420074,3.953349,0.05098039;1.216786,0.3015485,0.1974888,0.05098039;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode;226;224,256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;188;224,576;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;560,128;Inherit;False;Constant;_GlitchRemapMinOld;Glitch Remap Min Old;24;0;Create;True;0;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;560,224;Inherit;False;Constant;_GlitchRemapMaxOld;Glitch Remap Max Old;25;0;Create;True;0;0;0;False;0;False;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;202;560,352;Inherit;False;Constant;_GlitchRemapMinNew;Glitch Remap Min New;24;0;Create;True;0;0;0;False;0;False;-1;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;560,464;Inherit;False;Constant;_GlitchRemapMaxNew;Glitch Remap Max New;26;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;688;-80,-1216;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;611;-720,-3216;Inherit;False;1049.833;800.9198;Line 1;12;619;691;620;617;623;637;638;632;634;630;621;715;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;586;-352,-5040;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;584;-464,-5232;Inherit;True;Property;_NormalMap;NormalMap;3;0;Create;True;0;0;0;False;0;False;-1;None;d5ecf639375fb7641b0c39b0025bbf1f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;604;-416,-3856;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;186;304,-128;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;147;912,240;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;191;912,448;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;85;-736,-976;Inherit;False;1156.5;462.5211;Glitch Line 2;7;84;507;736;491;81;508;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;734;96,-1216;Inherit;False;Line 2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;694;-720,-6336;Inherit;False;2211.089;540.0215;Color Glitcht;18;689;181;175;184;183;174;176;168;166;396;395;167;383;163;386;164;165;160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;612;-704,-2400;Inherit;False;676.4335;328.5487;Line 2;6;733;636;635;633;631;627;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;587;-160,-5152;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-256,-3856;Inherit;False;maincolor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;691;-592,-2880;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;623;-688,-2496;Inherit;False;Property;_Line1InvertedThickness1;Line 1 Inverted Thickness;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;617;-624,-2576;Inherit;False;Property;_Line1Frequency1;Line 1 Frequency;12;0;Create;True;0;0;0;False;0;False;100;101;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;620;-592,-2656;Inherit;False;Property;_Line1Hardness1;Line 1 Hardness;13;0;Create;True;0;0;0;False;0;False;1.45;1.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;621;-624,-3152;Inherit;True;Property;_Line3;Line 1;10;2;[Header];[NoScaleOffset];Create;True;2;LINES;_;0;0;False;0;False;88eb97e78f86c604bb00864c0dbeffc1;ef301d4822ac111469bda406e1b4bc7c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;619;-592,-2736;Inherit;False;Property;_Line1Speed1;Line 1 Speed;11;0;Create;True;0;0;0;False;0;False;-3.57;-3.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;124;912,48;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;148;1120,240;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;192;1104,448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;198;1104,624;Inherit;False;Constant;_Float3;Float 3;35;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;84;-704,-912;Inherit;False;Property;_GlitchLine2Offset;Glitch Line 2 Offset;22;1;[Header];Create;True;2;GLITCH LINE 2;_;0;0;False;0;False;0.5,0,0;0.03,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;588;64,-5152;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;589;-16,-4928;Inherit;False;Property;_NormalAffect;NormalAffect;5;0;Create;True;0;0;0;False;0;False;0;0.589;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-704,-6112;Inherit;False;Constant;_ColorPeriodicSpeed;Color Periodic Speed;46;0;Create;True;0;0;0;False;0;False;-15;-15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;630;-224,-3040;Inherit;False;232;maincolor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;627;-608,-2336;Inherit;False;232;maincolor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;733;-656,-2256;Inherit;False;734;Line 2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;715;-352,-2960;Inherit;False;Hologram Line;-1;;178;a6b4840f4c8a45041b49734edbb63562;0;7;37;SAMPLER2D;0;False;44;FLOAT;0;False;43;FLOAT;0;False;13;FLOAT;1;False;14;FLOAT;1;False;15;FLOAT;2;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;199;1296,448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;1296,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;121;1088,-256;Inherit;False;Property;_RandomGlitchOffset;Random Glitch Offset;23;0;Create;True;0;0;0;False;0;False;-0.5,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;94;-496,-912;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectScaleNode;507;-480,-768;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;590;272,-5072;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;165;-480,-6112;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-544,-5936;Inherit;False;Constant;_ColorPeriodicSpeedX;Color Periodic Speed X;45;0;Create;True;0;0;0;False;0;False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;386;-512,-6192;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;634;-16,-3040;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;632;-224,-2736;Inherit;False;Property;_Line1Alpha1;Line 1 Alpha;15;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;631;-400,-2336;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;633;-592,-2160;Inherit;False;Property;_Line2Alpha;Line 2 Alpha;18;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;1472,304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;122;1360,-256;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectScaleNode;505;1392,-96;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;508;-240,-864;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;736;-272,-736;Inherit;False;734;Line 2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;281;-720,-5776;Inherit;False;1295.049;461.3077;Grain;9;268;269;270;278;264;272;602;265;273;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;563;-720,-4368;Inherit;False;1104.62;310.3358;Fresnel Opacity;7;579;577;575;565;573;569;566;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;591;432,-5072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;383;-208,-6192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;167;-272,-5936;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;395;-304,-6016;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-304,-6272;Inherit;False;Constant;_ColorPeriodcTiling;Color Periodc Tiling;38;0;Create;True;0;0;0;False;0;False;223;223;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;638;-16,-2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;637;128,-3040;Inherit;False;True;True;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;635;-240,-2336;Inherit;False;True;True;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;-400,-2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;196;1648,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;1488,624;Inherit;False;Property;_RandomGlitchAmount;Random Glitch Amount;24;0;Create;True;0;0;0;False;0;False;0.089;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;506;1616,-256;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-80,-768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;564;-720,-4816;Inherit;False;1093.118;409.6844;Fresnel;8;580;578;582;574;583;567;568;571;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;273;-704,-5392;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;265;-704,-5664;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IntNode;602;-704,-5504;Inherit;False;Property;_GrainScale;Grain Scale;20;0;Create;True;0;0;0;False;0;False;1000;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;566;-672,-4192;Inherit;False;Property;_FresnelAlphaPower;Fresnel Alpha Power;9;0;Create;True;0;0;0;False;0;False;2;3.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;565;-672,-4272;Inherit;False;Property;_FresnelAlphaScale;Fresnel Alpha Scale;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;592,-5072;Inherit;False;NormalAffect;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;396;-32,-5984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;166;-64,-6288;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;640;416,-2752;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;639;416,-2640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;1824,112;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;700;-736,-2000;Inherit;False;1108;626.95;Vertex Position;12;516;511;513;510;512;514;515;517;519;159;492;494;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;491;80,-768;Inherit;False;lineglitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;272;-480,-5568;Inherit;False;3;0;FLOAT3;1000,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;569;-432,-4320;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;573;-432,-4144;Inherit;False;594;NormalAffect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;567;-688,-4624;Inherit;False;Property;_FresnelPower;Fresnel Power;7;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;568;-688,-4704;Inherit;False;Property;_FresnelScale;Fresnel Scale;6;1;[Header];Create;True;2;FRESNEL;_;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;168;192,-6112;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;644;592,-2704;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;683;592,-2864;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;522;-720,-3552;Inherit;False;873.6426;255.0996;Alpha ;6;742;740;745;768;402;400;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;493;2032,112;Inherit;True;randomglitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;494;-704,-1744;Inherit;False;493;randomglitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;492;-672,-1840;Inherit;False;491;lineglitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;264;-272,-5568;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;575;-192,-4256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;571;-448,-4752;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;583;-448,-4576;Inherit;False;594;NormalAffect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;176;352,-6112;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;684;752,-2704;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;740;-704,-3520;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;742;-704,-3376;Inherit;False;Property;_AlphaHeight;Alpha Height;1;0;Create;True;0;0;0;False;0;False;0.76;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;510;-448,-1952;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-384,-1808;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;278;-32,-5600;Inherit;False;3;0;FLOAT;-1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;577;-48,-4256;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;-192,-4688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;582;-416,-4496;Inherit;False;232;maincolor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;174;640,-6112;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.61;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;270;-160,-5456;Inherit;False;Property;_GrainAffect;Grain Affect;19;1;[Header];Create;True;2;GRAIN;_;0;0;False;0;False;1;0.271;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;650;880,-2704;Inherit;False;line_color;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;745;-464,-3440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;-448,-1600;Inherit;False;Property;_Voxelization;Voxelization;28;0;Create;True;0;0;0;False;0;False;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;512;-224,-1808;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;269;192,-5520;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;578;-48,-4592;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;183;864,-6208;Inherit;False;Constant;_Float1;Float 1;47;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;175;880,-6112;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;184;736,-5904;Inherit;False;Property;_GlitchColorAffect;Glitch Color Affect;21;1;[Header];Create;True;2;GLITCH COLOR ;_;0;0;False;0;False;0.5;0.153;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;579;144,-4256;Inherit;False;fresnelalpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;654;1520,-3632;Inherit;False;650;line_color;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;768;-352,-3440;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;513;-256,-1600;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;580;128,-4592;Inherit;False;fresnelcolor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;181;1088,-6112;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;352,-5520;Inherit;False;grain;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;657;1728,-3440;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;653;1760,-3520;Inherit;False;579;fresnelalpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;400;-208,-3488;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;514;-416,-1712;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;601;1840,-3776;Inherit;False;268;grain;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;603;1840,-3712;Inherit;False;232;maincolor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;1840,-3856;Inherit;False;580;fresnelcolor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;656;1808,-3632;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;689;1248,-6112;Inherit;False;ColorGlitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;676;1968,-3488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;402;-64,-3488;Inherit;False;alphamask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;-352,-1488;Inherit;False;Property;_VoxelizationAffect;Voxelization Affect;29;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;515;-256,-1712;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;599;2064,-3808;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;690;1840,-3936;Inherit;False;689;ColorGlitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;677;2112,-3552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;406;2080,-3664;Inherit;False;402;alphamask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;517;-64,-1776;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;2208,-3936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;2288,-3664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;519;112,-1776;Inherit;False;ModifiedVertexPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;679;2416,-3808;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;595;32,-3936;Inherit;False;Constant;_ConstantZero;Constant Zero;47;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;596;240,-3936;Inherit;False;C_ZERO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;695;2528,-3600;Inherit;False;519;ModifiedVertexPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;680;2544,-3728;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;523;1968,-3984;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;530;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;529;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;528;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;True;_ZWrite;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;531;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;526;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;525;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;527;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;532;2186.873,-698.6207;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;534;2186.873,-598.6207;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;MotionVectors;0;10;MotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=MotionVectors;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;524;2800,-3808;Half;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;13;Hologram Shader IA;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;_CullMode;False;False;False;False;False;False;False;False;True;True;True;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;6;d3d11;glcore;gles;gles3;metal;vulkan;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;_Alpha;True;3;False;;True;False;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;27;Surface;1;637972967283466847;  Blend;0;638751246854332985;Two Sided;0;638751281489639942;Alpha Clipping;0;638701363033569914;  Use Shadow Threshold;0;0;Forward Only;0;638751281839009918;Cast Shadows;0;637972967296698888;Receive Shadows;0;637972967305116547;Motion Vectors;1;0;  Add Precomputed Velocity;0;638750438578206950;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;Meta Pass;0;638751247411743498;Extra Pre Pass;0;638751247367536031;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;638751281890919512;  Early Z;1;638751249679503756;Vertex Position,InvertActionOnDeselection;0;637972966021148095;0;11;False;True;False;False;False;False;False;False;False;False;True;False;;False;0
WireConnection;149;0;769;1
WireConnection;152;0;760;2
WireConnection;152;1;151;0
WireConnection;152;2;149;0
WireConnection;155;0;769;2
WireConnection;153;0;152;0
WireConnection;153;1;155;0
WireConnection;761;0;769;3
WireConnection;771;0;153;0
WireConnection;685;0;613;0
WireConnection;737;0;687;2
WireConnection;737;1;738;0
WireConnection;762;0;761;0
WireConnection;194;0;193;0
WireConnection;194;1;771;0
WireConnection;686;0;737;0
WireConnection;686;1;685;0
WireConnection;226;0;762;0
WireConnection;226;1;225;0
WireConnection;188;0;194;0
WireConnection;688;0;686;0
WireConnection;584;5;585;0
WireConnection;604;0;231;5
WireConnection;604;1;605;5
WireConnection;186;0;153;0
WireConnection;147;0;226;0
WireConnection;147;1;126;0
WireConnection;147;2;127;0
WireConnection;147;3;202;0
WireConnection;147;4;129;0
WireConnection;191;0;188;0
WireConnection;191;1;126;0
WireConnection;191;2;127;0
WireConnection;191;3;202;0
WireConnection;191;4;129;0
WireConnection;734;0;688;0
WireConnection;587;0;584;0
WireConnection;587;1;586;0
WireConnection;232;0;604;0
WireConnection;124;0;186;0
WireConnection;124;1;126;0
WireConnection;124;2;127;0
WireConnection;124;3;202;0
WireConnection;124;4;129;0
WireConnection;148;0;147;0
WireConnection;192;0;191;0
WireConnection;588;0;587;0
WireConnection;715;37;621;0
WireConnection;715;43;691;2
WireConnection;715;13;619;0
WireConnection;715;14;620;0
WireConnection;715;15;617;0
WireConnection;715;16;623;0
WireConnection;199;1;192;0
WireConnection;199;2;198;0
WireConnection;197;0;124;0
WireConnection;197;1;148;0
WireConnection;94;0;84;0
WireConnection;590;1;588;0
WireConnection;590;2;589;0
WireConnection;165;0;160;0
WireConnection;634;0;630;0
WireConnection;634;1;715;0
WireConnection;631;0;627;0
WireConnection;631;1;733;0
WireConnection;201;0;197;0
WireConnection;201;1;199;0
WireConnection;122;0;121;0
WireConnection;508;0;94;0
WireConnection;508;1;507;0
WireConnection;591;0;590;0
WireConnection;383;0;386;0
WireConnection;383;1;165;0
WireConnection;167;0;164;0
WireConnection;638;0;715;0
WireConnection;638;1;632;0
WireConnection;637;0;634;0
WireConnection;635;0;631;0
WireConnection;636;0;733;0
WireConnection;636;1;633;0
WireConnection;196;0;197;0
WireConnection;196;1;201;0
WireConnection;506;0;122;0
WireConnection;506;1;505;0
WireConnection;81;0;508;0
WireConnection;81;1;736;0
WireConnection;594;0;591;0
WireConnection;396;0;395;0
WireConnection;396;1;167;0
WireConnection;166;1;163;0
WireConnection;166;2;383;0
WireConnection;640;0;637;0
WireConnection;640;1;635;0
WireConnection;639;0;638;0
WireConnection;639;1;636;0
WireConnection;123;0;506;0
WireConnection;123;1;196;0
WireConnection;123;2;128;0
WireConnection;491;0;81;0
WireConnection;272;0;265;0
WireConnection;272;1;602;0
WireConnection;272;2;273;0
WireConnection;569;2;565;0
WireConnection;569;3;566;0
WireConnection;168;0;166;0
WireConnection;168;1;396;0
WireConnection;644;0;640;0
WireConnection;644;3;639;0
WireConnection;683;3;638;0
WireConnection;493;0;123;0
WireConnection;264;0;272;0
WireConnection;575;0;569;0
WireConnection;575;1;573;0
WireConnection;571;2;568;0
WireConnection;571;3;567;0
WireConnection;176;0;168;0
WireConnection;684;0;683;0
WireConnection;684;1;644;0
WireConnection;159;0;492;0
WireConnection;159;1;494;0
WireConnection;278;2;264;0
WireConnection;577;0;575;0
WireConnection;574;0;571;0
WireConnection;574;1;583;0
WireConnection;174;0;176;0
WireConnection;650;0;684;0
WireConnection;745;0;740;2
WireConnection;745;1;742;0
WireConnection;512;0;510;0
WireConnection;512;1;159;0
WireConnection;269;1;278;0
WireConnection;269;2;270;0
WireConnection;578;0;574;0
WireConnection;578;1;582;0
WireConnection;578;2;577;0
WireConnection;175;0;174;0
WireConnection;579;0;577;0
WireConnection;768;0;745;0
WireConnection;513;0;512;0
WireConnection;513;1;511;0
WireConnection;580;0;578;0
WireConnection;181;0;183;0
WireConnection;181;1;175;0
WireConnection;181;2;184;0
WireConnection;268;0;269;0
WireConnection;657;0;654;0
WireConnection;400;1;605;4
WireConnection;400;2;768;0
WireConnection;514;0;513;0
WireConnection;656;0;654;0
WireConnection;689;0;181;0
WireConnection;676;0;653;0
WireConnection;676;1;657;0
WireConnection;402;0;400;0
WireConnection;515;0;514;0
WireConnection;515;1;511;0
WireConnection;599;0;437;0
WireConnection;599;1;601;0
WireConnection;599;2;603;0
WireConnection;599;3;656;0
WireConnection;677;0;676;0
WireConnection;517;0;512;0
WireConnection;517;1;515;0
WireConnection;517;2;516;0
WireConnection;185;0;690;0
WireConnection;185;1;599;0
WireConnection;652;0;406;0
WireConnection;652;1;677;0
WireConnection;519;0;517;0
WireConnection;679;0;185;0
WireConnection;679;3;652;0
WireConnection;596;0;595;0
WireConnection;680;0;679;0
WireConnection;524;2;679;0
WireConnection;524;3;680;0
WireConnection;524;5;695;0
ASEEND*/
//CHKSM=1872D65309F10532AE574472E94F9883F8B905E8