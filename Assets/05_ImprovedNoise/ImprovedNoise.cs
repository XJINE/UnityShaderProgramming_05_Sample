using UnityEngine;

public class ImprovedNoise
{
    // https://gist.github.com/Flafla2/f0260a861be0ebdeef76
    // https://postd.cc/understanding-perlin-noise/
    // http://adrianb.io/2014/08/09/perlinnoise.html
    // https://edom18.hateblo.jp/entry/2018/10/11/140401#%E3%83%91%E3%83%BC%E3%83%AA%E3%83%B3%E3%83%8E%E3%82%A4%E3%82%BA%E3%81%AE%E8%80%83%E3%81%88%E3%81%8B%E3%81%9F
    // https://mrl.nyu.edu/~perlin/paper445.pdf

    static public float noise(float x, float y, float z)
    {
        // 単位立方体を見つける。

        int X = (int)Mathf.Floor(x) & 255;
        int Y = (int)Mathf.Floor(y) & 255;
        int Z = (int)Mathf.Floor(z) & 255;

        // 立方体の中の座標を算出する。

        x -= Mathf.Floor(x);
        y -= Mathf.Floor(y);
        z -= Mathf.Floor(z);

        // 補完した座標を算出する。

        float pX = fade(x);
        float pY = fade(y);
        float pZ = fade(z);

        // HASH COORDINATES OF THE 8 CUBE CORNERS,

        // 立方体の頂点 8 点の座標

        int  A = p[X    ] + Y;
        int AA = p[A    ] + Z; // p[ p[X    ] + Y ] + Z
        int AB = p[A + 1] + Z; // p[ p[X + Y] + 1 ] + Z

        int B  = p[X + 1] + Y;
        int BA = p[B    ] + Z; // p[ p[X + 1] + Y    ] + Z
        int BB = p[B + 1] + Z; // p[ p[X + 1] + Y + 1] + Z

        // AND ADD BLENDED RESULTS FROM 8 CORNERS OF CUBE

        // X 軸の補間
        float lerp_AA_BA = lerp(pX, grad(p[AA], x,     y,     z),
                                    grad(p[BA], x - 1, y,     z));

        float lerp_AB_BB = lerp(pX, grad(p[AB], x,     y - 1, z),
                                    grad(p[BB], x - 1, y - 1, z));

        float lerp_AA1_BA1 = lerp(pX, grad(p[AA + 1], x,     y, z - 1),
                                      grad(p[BA + 1], x - 1, y, z - 1));

        float lerp_AB1_BB1 = lerp(pX, grad(p[AA + 1], x,     y, z - 1),
                                      grad(p[BA + 1], x - 1, y, z - 1));

        float lerp_AA_BA_AB_BB     = lerp(pY, lerp_AA_BA,   lerp_AB_BB);
        float lerp_AA1_BA1_AB1_BB1 = lerp(pY, lerp_AA1_BA1, lerp_AB1_BB1);

        float lerpZ = lerp(pZ, lerp_AA_BA_AB_BB, lerp_AA1_BA1_AB1_BB1);

        return lerpZ;

        //return lerp(pZ, lerp(pY, lerp(pX, grad(p[AA    ], x    , y    , z    ),
        //                                  grad(p[BA    ], x - 1, y    , z    )),
        //                         lerp(pX, grad(p[AB    ], x    , y - 1, z    ),
        //                                  grad(p[BB    ], x - 1, y - 1, z    ))),
        //                lerp(pY, lerp(pX, grad(p[AA + 1], x    , y    , z - 1),
        //                                  grad(p[BA + 1], x - 1, y    , z - 1)),
        //                         lerp(pX, grad(p[AB + 1], x    , y - 1, z - 1),
        //                                  grad(p[BB + 1], x - 1, y - 1, z - 1))));
    }

    public static float fade(float t)
    {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    public static float lerp(float t, float a, float b)
    {
        return a + t * (b - a);
    }

    public static float grad(int hash, float x, float y, float z)
    {
        // CONVERT LO 4 BITS OF HASH CODE
        // INTO 12 GRADIENT DIRECTIONS.

        int h = hash & 15;

        float u = h < 8 ? x : y,
              v = h < 4 ? y : h == 12 || h == 14 ? x : z;

        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
   }

    public static float _grad(int hash, float x, float y, float z)
    {
        switch (hash & 0xF)
        {
            case 0x0: return  x + y; // ( 1,  1,  0)
            case 0x1: return -x + y; // (-1,  1,  0)
            case 0x2: return  x - y; // ( 1, -1,  0)
            case 0x3: return -x - y; // (-1, -1,  0)
            case 0x4: return  x + z; // ( 1,  0,  1)
            case 0x5: return -x + z; // (-1,  0,  1)
            case 0x6: return  x - z; // ( 1,  0, -1)
            case 0x7: return -x - z; // (-1,  0, -1)
            case 0x8: return  y + z; // ( 0,  1,  1)
            case 0x9: return -y + z; // ( 0, -1,  1)
            case 0xA: return  y - z; // ( 0,  1, -1)
            case 0xB: return -y - z; // ( 0, -1, -1)

            // 追加された分
            //case 0xC: return  y + x; // ( 1,  1,  0)
            //case 0xD: return -y + z; // (-1,  1,  0)
            //case 0xE: return  y - x; // ( 0, -1,  1)
            //case 0xF: return -y - z; // ( 0, -1, -1)

            case 0xC: return  x + y; // ( 1,  1,  0)
            case 0xD: return -x + y; // (-1,  1,  0)
            case 0xE: return -y + z; // ( 0, -1,  1)
            case 0xF: return -y - z; // ( 0, -1, -1)

            default: return 0; // never happens
        }
    }

    public static int[] p = new int[512];

    public static int[] permutation =
    {
        151,160,137,91,90,15,
        131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
        190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
        88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
        77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
        102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
        135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
        5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
        223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
        129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
        251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
        49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
        138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
    };

   static ImprovedNoise()
   {
        for (int i = 0; i < 256; i++)
        {
            p[256 + i] = p[i] = permutation[i];
        }
    }
}