Shader "Sample/Dot"
{
    Properties { }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex   vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 frag(v2f_img i) : SV_Target
            {
                float2 c = float2(0.5, 0.5);
                float2 y = float2(0, 1);
                float2 v = normalize(i.uv - c);

                return dot(y, v) * 0.5 + 0.5;
            }

            ENDCG
        }
    }
}