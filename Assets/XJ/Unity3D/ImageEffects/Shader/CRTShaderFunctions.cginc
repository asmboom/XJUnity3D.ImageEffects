#include "./Library/ColorBlend.cginc"
#include "./Library/Math.cginc"

// ------------------------------------------------------------------------------------------------
// ゴーストを追加する。CRT では直前の映像が残ることがある。
// ------------------------------------------------------------------------------------------------
float4 AddGhost(float4 color, sampler2D ghostImage, float2 texCoord, float ghostStrength)
{
    //return tex2D(ghostImage, texCoord);
    return BlendAlpha(color, tex2D(ghostImage, texCoord), ghostStrength);
}

// ------------------------------------------------------------------------------------------------
// テクスチャベースでノイズを追加して暗くする。CRT では各素子の出力が安定しない。
// ------------------------------------------------------------------------------------------------
float4 AddNoise(float4 color, sampler2D noiseImage, float2 texCoord, float noiseStrength)
{
    // noiseStrength が大きいほど暗くなるようにするのがベスト。

    float4 noise = tex2D(noiseImage, texCoord);
    color.rgb *= noise.r * noiseStrength;

    return color;
}

// ------------------------------------------------------------------------------------------------
// ノイズを追加して暗くする。CRT では各素子の出力が安定しない。
// ------------------------------------------------------------------------------------------------
float4 AddNoise(float4 color, float2 texCoord, int noiseSeed, float noiseStrength)
{
    // noiseStrength が大きいほど暗くなるようにするのがベスト。

    float noise = GetRandomValue(texCoord, noiseSeed);
    color.rgb *= 1 - (noise.r * noiseStrength);

    return color;
}

// ------------------------------------------------------------------------------------------------
// 角の陰りを追加する(角の発色が悪い)。
// ------------------------------------------------------------------------------------------------
float4 AddEdgeShadow(float4 color, float2 texCoord, float edgeShadowStrength)
{
    // (1) 座標を中心を原点とする座標に変換する。
    // (2) 中心からの距離を算出する。
    // (3) 中心からの距離が画像の半分より小さいときは、色をそのまま返す。
    //     すなわち、画像の四隅だけが次の処理に移行する(中心から円を描くイメージ)。
    // (4) 四隅の画素は暗くして返す。

    float2 centerOriginPosition = texCoord - 0.5f;

    float length = sqrt(centerOriginPosition.x * centerOriginPosition.x
                      + centerOriginPosition.y * centerOriginPosition.y);
    length -= 0.5;

    if (length < 0)
    {
        return color;
    }

    length = 1 - length * edgeShadowStrength;
    color.rgb *= length;

    return color;
}

// ------------------------------------------------------------------------------------------------
// 反射光(CRTのガラス面の輝き)を追加する。
// ------------------------------------------------------------------------------------------------
float4 AddReflection(float4 color, float2 texCoord, float2 texCoordDistorted,
                     float3 lightPosition, float4 lightColor)
{
    //Light
    float3 EyePosition = float3(0, 0, 2);

    //Calc Distorted Ratio
    //If movement length is quite small, the surface normal is close to front-way. 

    // (1) 歪み率を算出し、仮想の法線を設定する。

    float xDistRatio = texCoord.x - texCoordDistorted.x;
    float yDistRatio = texCoord.y - texCoordDistorted.y;
    float3 normal = float3(xDistRatio, yDistRatio, 1);
    normal = normalize(normal);

    // (2) 座標を、画像の中心を原点とする。
    //     Z 軸は 1 が最大となるようにする。

    float3 pixelPosition = float3(texCoordDistorted.x - 0.5f,
                                  texCoordDistorted.y - 0.5f,
                                  1 - (abs(xDistRatio) + abs(yDistRatio)));

    // (2.1) Debug Surface Position
    //return float4(pixelPosition.x + 0.5f, pixelPosition.y + 0.5f, pixelPosition.z, 1);

    // (3) Blind シェーディングを行う。

    float intensity = 10.0f;
    float Ks = 0.8f; //素材の反射係数

    // V = 視線ベクトル(View Vector)。
    float3 V = normalize(EyePosition - pixelPosition);

    // H = Half Vector.
    // LightPosition - pixelPosition = LightDirection
    float3 H = normalize(lightPosition - pixelPosition + V);    

    // 反射光を算出する。
    float specularLight = pow(dot(normal, H), intensity);
    float4 specular = Ks * lightColor * specularLight;

    // (5.1) Debug Reflection Color
    //return float4(specular.r, specular.g, specular.b, 1);

    // (6) 反射光の色を足して返す。

    return color + specular; //color.rgb + specular.rgb;
}

// ------------------------------------------------------------------------------------------------
// 反射して映り込ませるテクスチャを追加する。
// ------------------------------------------------------------------------------------------------
float4 AddGlare(float4 color, sampler2D glareImage, float2 texCoord, float glareStrength)
{
    // アルファブレンディングでない点に注意します。

    float4 glareColor = tex2D(glareImage, texCoord) * glareStrength;

    return color + glareColor;
}

// ------------------------------------------------------------------------------------------------
// 樽型歪み後の座標を取得する。
// ------------------------------------------------------------------------------------------------
float2 GetBarrelDistortedCoord(float2 texCoord)
{
    //Distortion Strength
    float BarellDistortionK1 = 0.2;
    float BarellDistortionK2 = 0.01;

    float k1 = BarellDistortionK1;
    float k2 = BarellDistortionK2;

    // (1) 中心を原点とする座標に変換します。
    float2 centerOriginPosition = texCoord - 0.5;


    // (2) 歪んだ座標を取得します。
    float2 distortedPosition;
    float rr = centerOriginPosition.x * centerOriginPosition.x
             + centerOriginPosition.y * centerOriginPosition.y;
    distortedPosition.x = centerOriginPosition.x * (1 + k1 * rr + k2 * rr * rr);
    distortedPosition.y = centerOriginPosition.y * (1 + k1 * rr + k2 * rr * rr);

    // (3) テクスチャ座標系に戻します。
    distortedPosition.x += 0.5;
    distortedPosition.y += 0.5;

    // (4) はみ出した領域を巻きます。

    if (distortedPosition.x > 1 || distortedPosition.y > 1
     || distortedPosition.x < 0 || distortedPosition.y < 0)
    {
        // 処理の都合上、はみ出した時には必ず -1 を返しておいた方が都合が良い。

        return float2(-1, -1);
    }

    return distortedPosition;
}

// ------------------------------------------------------------------------------------------------
// ShadowMask タイプの色を取得する。
// texCoord は、歪んでいない座標でも、歪んでいる座標でも良い。
// ------------------------------------------------------------------------------------------------
float4 GetShadowMaskColor(sampler2D image, float2 texCoord, float2 imageSize, float2 pixelSize)
{
    if (texCoord.x == -1)
    {
        return float4(0, 0, 0, 1);
    }

    // column, row は出力する座標で考え、実際に色を取得するときは、
    // 解像度が 3 分の 1 となるような座標で考える。

    int column = round(texCoord.x * imageSize.x + 0.5) % 3;
    int row    = round(texCoord.y * imageSize.y + 0.5);

    float4 color = 0.0f;

    // (1) 偶数行のとき、
    // 0 列目は、今のピクセルの R,
    // 1 列目は、隣のピクセルの G,
    // 2 列目は、隣のピクセルの B 

    if (row % 2 == 0)
    {
        if (column == 0)
        {
            color = tex2D(image, texCoord);
            color.gb = 0;
        }
        else if (column == 1)
        {
            texCoord.x += pixelSize.x;
            color = tex2D(image, texCoord);
            color.rb = 0;
        }
        else if (column == 2)
        {
            texCoord.x += pixelSize.x;
            color = tex2D(image, texCoord);
            color.rg = 0;
        }
    }

    // 奇数行のとき、
    // 0 列目は、今のピクセルの G,
    // 1 列目は、今のピクセルの B,
    // 2 列目は、隣のピクセルの R 

    else
    {
        if (column == 0)
        {
            color = tex2D(image, texCoord);
            color.rb = 0;
        }
        if (column == 1)
        {
            color = tex2D(image, texCoord);
            color.rg = 0;
        }
        if (column == 2)
        {
            texCoord.x += pixelSize.x;
            color = tex2D(image, texCoord);
            color.bg = 0;
        }
    }

    return color;
}

// ------------------------------------------------------------------------------------------------
// ApertureGrill タイプの色を取得する。
// texCoord は、歪んでいない座標でも、歪んでいる座標でも良い。
// ------------------------------------------------------------------------------------------------
float4 GetApertureGrillColor(sampler2D image, float2 texCoord, float2 imageSize)
{
    if (texCoord.x == -1)
    {
        return float4(0, 0, 0, 1);
    }

    // RGB 成分に分解するため、解像度は 3 分の 1 になる。
    // column の texCoord は、出力時の座標。
    // tex2D に与えている座標は、色を取得する座標。

    float4 color = tex2D(image, texCoord);
    int column = round(texCoord.x * imageSize.x + 0.5) % 3;
    
    // 以下のようにしても同じような結果が得られますがいくつかの問題があります。
    // (1) 演算回数が増し、特に除算の回数が増える。
    // (2) サイズが拡大縮小するときに誤差でやや望ましくない結果が得られる。
    //int column = round(texCoord.x % (pixelSize.x * 3) / pixelSize.x);

    if (column == 0)
    {
        color.gb = 0;
    }
    else if (column == 1)
    {
        color.rb = 0;
    }
    else
    {
        color.rg = 0;
    }

    return color;
}