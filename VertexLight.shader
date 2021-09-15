Shader "Unlit/VertexLight" 
{
	Properties
	{
		_MainTex("Base Texture", 2D) = "white" {}
		_AmbientLight("Ambient Light", Range(0,1)) = 0.05
		_LightPoint("Light Position", Vector) = (0,0,0,0)
		_LightIntensity("Light Intensity", Range(0,10)) = 5
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Lighting Off

		Pass 
		{
			CGPROGRAM
			#pragma vertex vert VertexLight
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD1;
				float intensity : TEXCOORD3;
				UNITY_FOG_COORDS(1)
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _LightPoint;
			float _LightIntensity;
			fixed _Cutoff;
			fixed _AmbientLight;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

				fixed3 lightDiff = o.worldPos - _LightPoint.xyz;
				fixed3 lightDir = normalize(lightDiff);
				fixed intensity = (-.5 * dot(lightDir, o.worldNormal) * .5);
				
				o.intensity = intensity * _LightIntensity;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_FOG(o,o.vertex);
				
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed intensity = clamp(i.intensity, _AmbientLight, _LightIntensity);
				fixed4 col = intensity * tex2D(_MainTex, i.texcoord);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}