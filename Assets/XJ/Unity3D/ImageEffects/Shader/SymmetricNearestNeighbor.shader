Shader "Hidden/SymmetricNearestNeighborFilter"
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

            #pragma vertex vert
            #pragma fragment frag
            
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
            int _ImageWidthPx;
            int _ImageHeightPx;
            int _FilterSizePx;

            fragmentInput vert(vertexInput input)
            {
                fragmentInput output;
                output.vertex = mul(UNITY_MATRIX_MVP, input.vertex);
                output.uv = input.uv;

                return output;
            }

            fixed4 frag (fragmentInput input) : SV_Target
            {
                fixed4 color = SymmetricNearestNeighborFilter
                      (_MainTex, int2(_ImageWidthPx, _ImageHeightPx), input.uv, _FilterSizePx);

                return color;
            }

            ENDCG
        }
    }
}