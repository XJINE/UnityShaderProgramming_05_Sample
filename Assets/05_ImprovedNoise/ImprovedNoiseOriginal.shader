Shader "Sample/ImprovedNoise"
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

            static const int permutation[512] =
            {
                151,160,137, 91, 90, 15,131, 13,201, 95, 96, 53,194,233,  7,225,
                140, 36,103, 30, 69,142,  8, 99, 37,240, 21, 10, 23,190,  6,148,
                247,120,234, 75,  0, 26,197, 62, 94,252,219,203,117, 35, 11, 32,
                 57,177, 33, 88,237,149, 56, 87,174, 20,125,136,171,168, 68,175,
                 74,165, 71,134,139, 48, 27,166, 77,146,158,231, 83,111,229,122,
                 60,211,133,230,220,105, 92, 41, 55, 46,245, 40,244,102,143, 54,
                 65, 25, 63,161,  1,216, 80, 73,209, 76,132,187,208, 89, 18,169,
                200,196,135,130,116,188,159, 86,164,100,109,198,173,186,  3, 64,
                 52,217,226,250,124,123,  5,202, 38,147,118,126,255, 82, 85,212,
                207,206, 59,227, 47, 16, 58, 17,182,189, 28, 42,223,183,170,213,
                119,248,152,  2, 44,154,163, 70,221,153,101,155,167, 43,172,  9,
                129, 22, 39,253, 19, 98,108,110, 79,113,224,232,178,185,112,104,
                218,246, 97,228,251, 34,242,193,238,210,144, 12,191,179,162,241,
                 81, 51,145,235,249, 14,239,107, 49,192,214, 31,181,199,106,157,
                184, 84,204,176,115,121, 50, 45,127,  4,150,254,138,236,205, 93,
                222,114, 67, 29, 24, 72,243,141,128,195, 78, 66,215, 61,156,180,

                151,160,137, 91, 90, 15,131, 13,201, 95, 96, 53,194,233,  7,225,
                140, 36,103, 30, 69,142,  8, 99, 37,240, 21, 10, 23,190,  6,148,
                247,120,234, 75,  0, 26,197, 62, 94,252,219,203,117, 35, 11, 32,
                 57,177, 33, 88,237,149, 56, 87,174, 20,125,136,171,168, 68,175,
                 74,165, 71,134,139, 48, 27,166, 77,146,158,231, 83,111,229,122,
                 60,211,133,230,220,105, 92, 41, 55, 46,245, 40,244,102,143, 54,
                 65, 25, 63,161,  1,216, 80, 73,209, 76,132,187,208, 89, 18,169,
                200,196,135,130,116,188,159, 86,164,100,109,198,173,186,  3, 64,
                 52,217,226,250,124,123,  5,202, 38,147,118,126,255, 82, 85,212,
                207,206, 59,227, 47, 16, 58, 17,182,189, 28, 42,223,183,170,213,
                119,248,152,  2, 44,154,163, 70,221,153,101,155,167, 43,172,  9,
                129, 22, 39,253, 19, 98,108,110, 79,113,224,232,178,185,112,104,
                218,246, 97,228,251, 34,242,193,238,210,144, 12,191,179,162,241,
                 81, 51,145,235,249, 14,239,107, 49,192,214, 31,181,199,106,157,
                184, 84,204,176,115,121, 50, 45,127,  4,150,254,138,236,205, 93,
                222,114, 67, 29, 24, 72,243,141,128,195, 78, 66,215, 61,156,180,
            };

            float dotGradient(int hash, float3 f)
            {
                switch (hash & 0xF)
                {
                    case 0x0: return  f.x + f.y; // ( 1,  1,  0)
                    case 0x1: return -f.x + f.y; // (-1,  1,  0)
                    case 0x2: return  f.x - f.y; // ( 1, -1,  0)
                    case 0x3: return -f.x - f.y; // (-1, -1,  0)
                    case 0x4: return  f.x + f.z; // ( 1,  0,  1)
                    case 0x5: return -f.x + f.z; // (-1,  0,  1)
                    case 0x6: return  f.x - f.z; // ( 1,  0, -1)
                    case 0x7: return -f.x - f.z; // (-1,  0, -1)
                    case 0x8: return  f.y + f.z; // ( 0,  1,  1)
                    case 0x9: return -f.y + f.z; // ( 0, -1,  1)
                    case 0xA: return  f.y - f.z; // ( 0,  1, -1)
                    case 0xB: return -f.y - f.z; // ( 0, -1, -1)

                    case 0xC: return  f.x + f.y; // ( 1,  1,  0)
                    case 0xD: return -f.x + f.y; // (-1,  1,  0)
                    case 0xE: return -f.y + f.z; // ( 0, -1,  1)
                    case 0xF: return -f.y - f.z; // ( 0, -1, -1)

                    default: return 0;
                }
            }

            float improvedNoise(float3 seeds)
            {
                int3   i = (int3)floor(seeds) & 255;
                float3 f = frac (seeds);

                int i000 = permutation[permutation[i.x    ] + i.y    ] + i.z;
                int i010 = permutation[permutation[i.x    ] + i.y + 1] + i.z;
                int i100 = permutation[permutation[i.x + 1] + i.y    ] + i.z;
                int i110 = permutation[permutation[i.x + 1] + i.y + 1] + i.z;

                float3 f000 = float3(f.x,     f.y,     f.z);
                float3 f100 = float3(f.x - 1, f.y,     f.z);
                float3 f010 = float3(f.x,     f.y - 1, f.z);
                float3 f110 = float3(f.x - 1, f.y - 1, f.z);

                float3 f001 = float3(f.x,     f.y,     f.z - 1);
                float3 f101 = float3(f.x - 1, f.y,     f.z - 1);
                float3 f011 = float3(f.x,     f.y - 1, f.z - 1);
                float3 f111 = float3(f.x - 1, f.y - 1, f.z - 1);

                float v000 = dotGradient(i000, f000);
                float v100 = dotGradient(i100, f100);
                float v010 = dotGradient(i010, f010);
                float v110 = dotGradient(i110, f110);

                float v001 = dotGradient(i000 + 1, f001);
                float v101 = dotGradient(i100 + 1, f101);
                float v011 = dotGradient(i010 + 1, f011);
                float v111 = dotGradient(i110 + 1, f111);

                float3 p = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

                float v000v100 = lerp(v000, v100, p.x);
                float v010v110 = lerp(v010, v110, p.x);
                float v001v101 = lerp(v001, v101, p.x);
                float v011v111 = lerp(v011, v111, p.x);

                float v000v100v010v110 = lerp(v000v100, v010v110, p.y);
                float v001v101v011v111 = lerp(v001v101, v011v111, p.y);

                float v = lerp(v000v100v010v110,
                               v001v101v011v111, p.z);

                return v * 0.5 + 0.5;
            }

            float _NoiseScale;
            float _NoiseAspect;

            float4 frag(v2f_img i) : SV_Target
            {
                i.uv   *= _NoiseScale;
                i.uv.x *= _NoiseAspect;

                return improvedNoise(float3(i.uv, 0));
            }

            ENDCG
        }
    }
}