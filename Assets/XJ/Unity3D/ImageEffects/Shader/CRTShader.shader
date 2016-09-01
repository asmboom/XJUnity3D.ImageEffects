Shader "Hidden/CRTShader"
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
            #include "./CRTShaderFunctions.cginc"

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
            float _ImageWidth;
            float _ImageHeight;
            float _PixelWidth;
            float _PixelHeight;

            bool _EnableBarrelDistortion;
            bool _ShadowMaskType;
            float _NoiseStrength;
            sampler2D _GhostTex;
            float _GhostStrength;
            float _EdgeShadowStrength;
            float3 _ReflectionLightPosition;
            float4 _ReflectionLightColor;
            sampler2D _GlareTex;
            float _GlareStrength;

            fragmentInput vertexShader (vertexInput input)
            {
                fragmentInput output;
                output.vertex = mul(UNITY_MATRIX_MVP, input.vertex);
                output.uv = input.uv;

                return output;
            }

            fixed4 fragmentShader (fragmentInput input) : SV_Target
            {
                float4 color;
                float2 normalTexCoord = input.uv;

                // (1) 歪み
                if (_EnableBarrelDistortion)
                {
                    input.uv = GetBarrelDistortedCoord(input.uv);
                }

                // (2) CRT 加工
                if (_ShadowMaskType)
                {
                    color = GetShadowMaskColor(_MainTex,
                                               input.uv,
                                               float2(_ImageWidth, _ImageHeight),
                                               float2(_PixelWidth, _PixelHeight));

                }
                else
                {
                    color = GetApertureGrillColor(_MainTex,
                                                  input.uv,
                                                  float2(_ImageWidth, _ImageHeight));
                }

                // ゴースト
                color = AddGhost(color, _GhostTex, float2(input.uv.x, -input.uv.y), _GhostStrength);

                // ノイズ
                color = AddNoise(color, input.uv, frac(_Time.y) * 10, _NoiseStrength);

                // 四隅の陰り
                color = AddEdgeShadow(color, input.uv, _EdgeShadowStrength);

                // 反射
                color = AddReflection(color, normalTexCoord, input.uv,
                    _ReflectionLightPosition, _ReflectionLightColor);

                // 映り込み
                color = AddGlare(color, _GlareTex, float2(input.uv.x, -input.uv.y), _GlareStrength);

                return color;
            }

            ENDCG
        }
    }
}