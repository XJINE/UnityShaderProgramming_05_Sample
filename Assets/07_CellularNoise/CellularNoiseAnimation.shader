Shader "Sample/CellularNoiseAnimation"
{
    Properties
    {
        _NoiseScale  ("Noise Scale",  Range(0, 50)) = 10
        _NoiseAspect ("Noise Aspect", Range(0, 10)) = 1
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

            float cellularNoise(float2 seeds)
            {
                float2 i = floor(seeds);
                float2 f = frac (seeds);

                float minDistance = 3;

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(x, y);

                        float2 p = random2(i + neighbor);
                               p = 0.5 + 0.5 * sin(p * (_Time.y + 100));

                        minDistance = min(minDistance, length(neighbor + p - f));
                    }
                }

                return minDistance;
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return cellularNoise(i.uv);
            }

            ENDCG
        }
    }
}