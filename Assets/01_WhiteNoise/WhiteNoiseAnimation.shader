﻿Shader "Sample/WhiteNoiseAnimation"
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
            #include "Assets/Common/Random.cginc"

            float whiteNoise(float2 seeds)
            {
                return random(seeds);
            }

            float4 frag(v2f_img i) : SV_Target
            {
                return whiteNoise(i.uv + _Time.x);
            }

            ENDCG
        }
    }
}