Shader "Hidden/TransparentWindow"
{
    // 実態は何もしないシェーダです。
    // 
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            Tags{ "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM

            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #include "UnityCG.cginc"

            // ------------------------------------------------------------------------------------
            // Strunct
            // ------------------------------------------------------------------------------------

            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct vertexShaderOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // ------------------------------------------------------------------------------------
            // Field
            // ------------------------------------------------------------------------------------

            sampler2D _MainTex;

            // ------------------------------------------------------------------------------------
            // Vertex Shader
            // ------------------------------------------------------------------------------------
            vertexShaderOutput vertexShader(appdata input)
            {
                vertexShaderOutput output;

                output.pos = mul(UNITY_MATRIX_MVP, input.pos);
                output.uv = input.uv;

                return output;
            }

            // ------------------------------------------------------------------------------------
            // Fragment Shader
            // ------------------------------------------------------------------------------------
            float4 fragmentShader(vertexShaderOutput input) : SV_Target
            {
                float4 color = tex2D(_MainTex, input.uv);
                return color;
            }

            ENDCG
        }
    }
}