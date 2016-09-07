Shader "Hidden/PixelArtShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        CGINCLUDE

        #include "UnityCG.cginc"
        #include "./PixelArtShaderFunctions.cginc"

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
        float _PixelWidth;
        float _PixelHeight;

        float4 _RgbColorPallet[256];
        int _RgbColorPalletLength;
        int _ResolutionDivision;

        fragmentInput vertexShader(vertexInput input)
        {
            fragmentInput output;
            output.vertex = mul(UNITY_MATRIX_MVP, input.vertex);
            output.uv = input.uv;

            return output;
        }

        ENDCG

        Pass
        {
            CGPROGRAM

            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            fixed4 fragmentShader(fragmentInput input) : SV_Target
            {
                // まずは解像度を落とす。
                return ScaledownWithPointSampling
                    (_MainTex, input.uv, _ResolutionDivision);
            }

            ENDCG
        }

        Pass
        {
            CGPROGRAM

            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            fixed4 fragmentShader(fragmentInput input) : SV_Target
            {
                //return tex2D(_MainTex, input.uv);

                return MapToPalletColorWithRgbEuclideanDistance(tex2D(_MainTex, input.uv),
                                                                _RgbColorPallet,
                                                                _RgbColorPalletLength);
            }

            ENDCG
        }
    }
}