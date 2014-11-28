Shader "MyDepth" {
   Properties {
   		_MainTex ("Diffuse Texture",2D) = "white" {}
   		_BlurTex ("Blur Texture",2D) = "white"	{}
   		_BlurSize ("Blur Size", Range (0.0,1.0)) = 1.0
   		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
   		_FogColor ("Fog Color", Color) = (1.0,1.0,1.0,1.0)
   		_RangeStart ("Fog Close Distance", Float) = 25
   		_RangeEnd ("Fog Far Distance", Float) = 25
   		
   }
   SubShader {
      Pass {
      	Tags {"LightMode" = "ForwardBase"}	
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
 
	    // Variables
	    uniform sampler2D _MainTex;
	    uniform half4 _MainTex_ST;
	    uniform sampler2D _BlurTex;
	    uniform half4 _BlurTex_ST;
	    uniform fixed _BlurSize;
	    uniform fixed4 _Color;
	    uniform fixed4 _FogColor;
	    uniform half _RangeStart;
	    uniform half _RangeEnd;
	    
	    
	    //Unity Variables
			
		struct vertexInput{
			half4 vertex : POSITION;
			half4 texcoord : TEXCOORD0;
		};
		
        struct vertexOutput{
			half4 pos : SV_POSITION;
			fixed depth : TEXCOORD0;
			half4 tex : TEXCOORD1;
		};
		
		
		//Vertex Function
		vertexOutput vert(vertexInput v) {
			vertexOutput o;
			
			// Unity transform position
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			
			//clapm z-depth to range
			o.depth = saturate( ( distance( mul(_Object2World, v.vertex) , _WorldSpaceCameraPos.xyz) - _RangeStart)/_RangeEnd );
			
			o.tex = v.texcoord;
			return o;
			
		}
		
		// Fragment Function
		fixed4 frag(vertexOutput i) : COLOR
		{
			//textures
			fixed4 tex = tex2D(_MainTex, _MainTex_ST.xy * i.tex.xy + _MainTex_ST.zw);
			fixed4 texB = tex2D(_BlurTex, _BlurTex_ST.xy * i.tex.xy + _BlurTex_ST.zw);
		
			//lerp based on distance
			fixed4 colorBlur = lerp(tex, texB, i.depth * _BlurSize);
		
			//return color
			return fixed4(colorBlur * _Color.xyz + i.depth * _FogColor.xyz, 1.0);
		}
        
         ENDCG
      }
   }
}