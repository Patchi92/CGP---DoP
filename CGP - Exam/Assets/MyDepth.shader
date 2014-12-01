Shader "MyDepth" {
   Properties {
   
   		// These are the properties that can be changed outsite the value, this could be the start and end point of the alpha blend.
   		
   		_MainTex ("Diffuse Texture",2D) = "white" {}
   		_DepthTex ("Depth Texture",2D) = "white"	{}
   		_DepthInt ("Depth Intensity", Range (0.0,1.0)) = 1.0
   		_Color ("Color Intensity", Color) = (1.0,1.0,1.0,1.0)
   		_DepthColor ("Depth Texture Intensity", Color) = (1.0,1.0,1.0,1.0)
   		_RangeStart ("Distance Start", Float) = 10
   		_RangeEnd ("Distance End", Float) = 20
   		
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
	    uniform sampler2D _DepthTex;
	    uniform half4 _DepthTex_ST;
	    uniform fixed _DepthInt;
	    uniform fixed4 _Color;
	    uniform fixed4 _DepthColor;
	    uniform half _RangeStart;
	    uniform half _RangeEnd;
	    
	    
	    //Unity Variables
	    
	    
	    // Struct for grafic card input
			
		struct vertexInput{
			half4 vertex : POSITION;
			half4 texcoord : TEXCOORD0;
		};
		
		
		// Struct for unity information
		
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
			
			
			// This line finds the object coords in the world and then finds the distance between the object and the camera.
			// When that is done the distance between the start and end point is reduced by the start range to make sure the alpha blend
			// won't take place earlier then our DoF. In the end we saturate the colors
			o.depth = saturate( ( distance( mul(_Object2World, v.vertex) , _WorldSpaceCameraPos.xyz) - _RangeStart)/_RangeEnd );
			
			
			o.tex = v.texcoord;
			return o;
			
		}
		
		// Fragment Function
		fixed4 frag(vertexOutput i) : COLOR
		{
			//textures
			fixed4 tex = tex2D(_MainTex, _MainTex_ST.xy * i.tex.xy + _MainTex_ST.zw);
			fixed4 texB = tex2D(_DepthTex, _DepthTex_ST.xy * i.tex.xy + _DepthTex_ST.zw);
		
			//lerp based on distance
			fixed4 colorChange = lerp(tex, texB, i.depth * _DepthInt);
		
			//return color
			return fixed4(colorChange * _Color.xyz + i.depth * _DepthColor.xyz, 1.0);
		}
        
         ENDCG
      }
   }
}