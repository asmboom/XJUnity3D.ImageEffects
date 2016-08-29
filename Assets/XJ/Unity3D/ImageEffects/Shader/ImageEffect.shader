Shader "Hidden/ImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

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

            fragmentInput vert (vertexInput input)
            {
                fragmentInput output;
                output.vertex = mul(UNITY_MATRIX_MVP, input.vertex);
                output.uv = input.uv;

                return output;
            }

            fixed4 frag (fragmentInput input) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, input.uv);
                return color;
            }

            ENDCG
        }
    }
}