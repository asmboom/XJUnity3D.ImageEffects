#include "./Library/ColorCollection.cginc"
// Upgrade NOTE: excluded shader from DX11, Xbox360, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 xbox360 gles

// ------------------------------------------------------------------------------------------------
// H, S, V 成分の分割数を指定し、HSV 色を減色します。
// ------------------------------------------------------------------------------------------------
float4 ReduceColorWithHslDivide
    (float4 hsvColor, int hueDivide, int saturationDivide, int valueDivide)
{
    // どういうアルゴリズムなのか失念しました。

    float hue = 1.0f / hueDivide;
    float saturation = 1.0f / saturationDivide;
    float value = 1.0f / valueDivide;

    hsvColor.x = (int)(hsvColor.x / hue + 0.5f) * hue;
    hsvColor.y = (int)(hsvColor.y / saturation + 0.5f) * saturation;
    hsvColor.z = (int)(hsvColor.z / value + 0.5f) * value;
    hsvColor.a = hsvColor.a;

    return hsvColor;
}

// ------------------------------------------------------------------------------------------------
// 入力された色を、ユークリッド距離を用いて、パレット上の色のいずれかにマップします。
// ------------------------------------------------------------------------------------------------
float4 MapToPalletColorWithEuclideanDistance
    (float4 rgbColor float4[] rgbPallet, int rgbPalletLength)
{
    // R,G,B の各成分の距離で比較します。
    // 各成分で一番長い距離は 0 ~ 1 の 1 になります。

    float minLength = 3; // RGB
    float tempLength = 0;
    float4 minLengthColor = rgbPallet[0];

    for (int i = 0; i < rgbPalletLength; i++)
    {
        tempLength = abs(rgbPallet[i].r - rgbColor.r)
                   + abs(rgbPallet[i].g - rgbColor.g)
                   + abs(rgbPallet[i].b - rgbColor.b);

        if (minLength > tempLength)
        {
            minLength = tempLength;
            minLengthColor = rgbPallet[i];
        }
    }

    return minLengthColor;
}

// ------------------------------------------------------------------------------------------------
// Point サンプリングで解像度を下げます。高速ですがディティールが損なわれます。
// ------------------------------------------------------------------------------------------------
float4 ScaledownWithPointSampling(sampler2D image, float2 texCoord, int divide)
{
    return tex2D(image, texCoord * divide);
}

// ------------------------------------------------------------------------------------------------
// Liner サンプリングで解像度を下げます。やや高度ですがディティールがわずかに残る可能性があります。
// ------------------------------------------------------------------------------------------------
float4 ScaledownWithLinerSampling(sampler2D image, float2 texCoord, float2 pixelSize, int divide)
{
    texCoord = texCoord * divide;

    float4 result = 0;
    int count = 0;

    for (int y = -divide / 2; y < divide / 2; y++)
    {
        for (int x = -divide / 2; x < divide / 2; x++)
        {
            result += tex2D(image, float2(texCoord.x + pixelSize.x * x,
                                          texCoord.y + pixelSize.y * y));
            count++;
        }
    }

    result.rgba /= count;

    return result;
}