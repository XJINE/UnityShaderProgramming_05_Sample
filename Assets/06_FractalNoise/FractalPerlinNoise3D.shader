Shader "Sample/FractalPerlinNoise3D"
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

            float perlinNoise3D(float3 seeds)
            {
                float3 i = floor(seeds);
                float3 f = frac (seeds);

                float3 i000 = i + float3(0, 0, 0);
                float3 i100 = i + float3(1, 0, 0);
                float3 i010 = i + float3(0, 1, 0);
                float3 i110 = i + float3(1, 1, 0);
                float3 i001 = i + float3(0, 0, 1);
                float3 i101 = i + float3(1, 0, 1);
                float3 i011 = i + float3(0, 1, 1);
                float3 i111 = i + float3(1, 1, 1);

                float3 f000 = f - float3(0, 0, 0);
                float3 f100 = f - float3(1, 0, 0);
                float3 f010 = f - float3(0, 1, 0);
                float3 f110 = f - float3(1, 1, 0);
                float3 f001 = f - float3(0, 0, 1);
                float3 f101 = f - float3(1, 0, 1);
                float3 f011 = f - float3(0, 1, 1);
                float3 f111 = f - float3(1, 1, 1);

                float3 g000 = normalize(-1 + 2 * random3(i000));
                float3 g100 = normalize(-1 + 2 * random3(i100));
                float3 g010 = normalize(-1 + 2 * random3(i010));
                float3 g110 = normalize(-1 + 2 * random3(i110));
                float3 g001 = normalize(-1 + 2 * random3(i001));
                float3 g101 = normalize(-1 + 2 * random3(i101));
                float3 g011 = normalize(-1 + 2 * random3(i011));
                float3 g111 = normalize(-1 + 2 * random3(i111));

                float v000 = dot(g000, f000);
                float v100 = dot(g100, f100);
                float v010 = dot(g010, f010);
                float v110 = dot(g110, f110);
                float v001 = dot(g001, f001);
                float v101 = dot(g101, f101);
                float v011 = dot(g011, f011);
                float v111 = dot(g111, f111);

                float3 p = smoothstep(0, 1, f);

                float v000v100 = lerp(v000, v100, p.x);
                float v010v110 = lerp(v010, v110, p.x);
                float v001v101 = lerp(v001, v101, p.x);
                float v011v111 = lerp(v011, v111, p.x);

                float v000v100v010v110 = lerp(v000v100, v010v110, p.y);
                float v001v101v011v111 = lerp(v001v101, v011v111, p.y);

                return lerp(v000v100v010v110,
                            v001v101v011v111, p.z) * 0.5 + 0.5;
            }

            float fractalPerlinNoise3D(float3 seeds, int octaves)
            {
                float value     = 0.0;
                float amplitude = 0.5;

                for (int i = 0; i < octaves; i++)
                {
                    value += perlinNoise3D(seeds) * amplitude;

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

                return fractalPerlinNoise3D(float3(i.uv, _Time.y), _NoiseOctaves);
            }

            ENDCG
        }
    }
}