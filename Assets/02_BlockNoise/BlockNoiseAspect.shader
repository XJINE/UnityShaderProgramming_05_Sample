﻿Shader "Sample/BlockNoiseAspect"
{
    Properties
    {
        _NoiseScale  ("Noise Scale",  Range(0, 50)) = 10
        _NoiseAspect ("Noise Aspect", Range(0, 10)) =  1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex   vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Common/Random.cginc"

            float blockNoise(float2 seeds)
            {
                return random(floor(seeds));
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv.x *= _NoiseAspect;

                return blockNoise(i.uv * _NoiseScale);
            }

            ENDCG
        }
    }
}