Shader "Sample/FractalBlockNoise"
{
    Properties
    {
                   _NoiseScale   ("Noise Scale",   Range(0, 50)) = 10
                   _NoiseAspect  ("Noise Aspect",  Range(0, 10)) =  1
        [IntRange] _NoiseOctaves ("Noise Octaves", Range(1,  5)) =  1
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

            float fractalBlockNoise(float2 seeds, int octaves)
            {
                float value     = 0.0;
                float amplitude = 0.5;

                for (int i = 0; i < octaves; i++)
                {
                    value += blockNoise(seeds) * amplitude;

                    seeds     *= 2.0;
                    amplitude *= 0.5;
                }

                return value;
            }

            float _NoiseScale;
            float _NoiseAspect;
            int   _NoiseOctaves;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return fractalBlockNoise(i.uv, _NoiseOctaves);
            }

            ENDCG
        }
    }
}