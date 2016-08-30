﻿Shader "Hidden/DotTypeDitheringFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FilterSizePx("FilterSize", Int) = 5
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM

            #pragma target 4.0;
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            
            #include "UnityCG.cginc"
            #include "./Library/ImageFilter.cginc"

            struct vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct fragmentInput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            int _ImageSizeWidth;
            int _ImageSizeHeight;

            fragmentInput vertexShader (vertexInput input)
            {
                fragmentInput output;
                output.vertex = mul(UNITY_MATRIX_MVP, input.vertex);
                output.uv = input.uv;

                return output;
            }

            fixed4 fragmentShader (fragmentInput input) : SV_Target
            {
                return DotTypeDitheringFilter
                        (_MainTex,
                         int2(_ImageSizeWidth, _ImageSizeHeight),
                         input.uv);
            }

            ENDCG
        }
    }
}