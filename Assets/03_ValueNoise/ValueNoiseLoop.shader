Shader "Sample/ValueNoiseLoop"
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

            float valueNoiseLoop(float2 seeds, float2 scale)
            {
                scale  = floor(scale);
                seeds *= scale;

                float2 i = floor(seeds);
                float2 f = frac (seeds);

                bool2  loop   = i == (scale - 1);
                float2 offset = float2(loop.x ? -i.x : 1,
                                       loop.y ? -i.y : 1);

                float2 i00 = i + float2(       0,        0);
                float2 i10 = i + float2(offset.x,        0);
                float2 i01 = i + float2(       0, offset.y);
                float2 i11 = i + float2(offset.x, offset.y);

                float v00 = random(i00);
                float v10 = random(i10);
                float v01 = random(i01);
                float v11 = random(i11);

                float2 p = smoothstep(0, 1, f);

                float v00v10 = lerp(v00, v10, p.x);
                float v01v11 = lerp(v01, v11, p.x);

                return lerp(v00v10, v01v11, p.y);
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                float2 scale    = _NoiseScale;
                       scale.x *= _NoiseAspect;

                return valueNoiseLoop(i.uv, scale);
            }

            ENDCG
        }
    }
}