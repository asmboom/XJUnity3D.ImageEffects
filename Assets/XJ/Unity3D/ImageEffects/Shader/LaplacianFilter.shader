﻿Shader "Hidden/LaplacianFilter"
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
            float _PixelLengthWidth;
            float _PixelLengthHeight;

            fragmentInput vertexShader (vertexInput input)
            {
                fragmentInput output;
                output.vertex = mul(UNITY_MATRIX_MVP, input.vertex);
                output.uv = input.uv;

                return output;
            }

            fixed4 fragmentShader (fragmentInput input) : SV_Target
            {
                return LaplacianFilter
                        (_MainTex,
                         float2(_PixelLengthWidth, _PixelLengthHeight),
                         input.uv);
            }

            ENDCG
        }
    }
}