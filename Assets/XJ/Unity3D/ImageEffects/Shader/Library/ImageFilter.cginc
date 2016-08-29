#ifndef XJSHADERLIBRARY_IMAGEFILTER_INCLUDED
#define XJSHADERLIBRARY_IMAGEFILTER_INCLUDED
#include "./ColorCollection.cginc"

float PrewittHorizontalFilter[9] =
{ -1, 0, 1,
  -1, 0, 1,
  -1, 0, 1 };

float PrewittVerticalFilter[9] =
{ -1, -1, -1,
   0,  0,  0,
   1,  1,  1 };

float SobelHorizontalFilter[9] =
{ -1, 0, 1,
  -2, 0, 2,
  -1, 0, 1 };

float SobelVerticalFilter[9] =
{ -1, -2, -1,
   0,  0,  0,
   1,  2,  1 };

float4x4 DotDitherMatrix =
{ { 0.74, 0.27, 0.40, 0.60 } ,
  { 0.80,    0, 0.13, 0.94 },
  { 0.47, 0.54, 0.67, 0.34 },
  { 0.20, 1.00, 0.87, 0.07 } };

//-------------------------------------------------------------------------------------------------
// Dithering Filter (Dot type)
//-------------------------------------------------------------------------------------------------
float4 DotTypeDitheringFilter(sampler2D image, int2 imageSize, float2 inputPos)
{
    float4 grayColor = RgbToGray(tex2D(image, inputPos));

    int2 coordinatePx;
    coordinatePx.x = round((inputPos.x * imageSize.x) + 0.5);
    coordinatePx.y = round((inputPos.y * imageSize.y) + 0.5);

    if (DotDitherMatrix[coordinatePx.x % 4][coordinatePx.y % 4] < grayColor.r)
        return float4(0, 0, 0, grayColor.a);
    else
        return float4(1, 1, 1, grayColor.a);
}

//-------------------------------------------------------------------------------------------------
// Prewitt Filter
//-------------------------------------------------------------------------------------------------
float4 PrewittFilter(sampler2D image, float2 pixelLength, float2 texCoord)
{
    float4 sumHorizontal = float4(0, 0, 0, 1);
    float4 sumVertical = float4(0, 0, 0, 1);
    float2 coordinate;
    int count = 0; //x,yから求めるより結果的に演算数が減る

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            coordinate = float2(texCoord.x + pixelLength.x * x, texCoord.y + pixelLength.y * y);
            sumHorizontal.rgb += tex2D(image, coordinate).rgb * PrewittHorizontalFilter[count];
            sumVertical.rgb += tex2D(image, coordinate).rgb * PrewittVerticalFilter[count];
            count++;
        }
    }

    float4 color = float4(0, 0, 0, 1);

    color.rgb = sqrt(sumHorizontal * sumHorizontal + sumVertical * sumVertical);

    return color;
}

//-------------------------------------------------------------------------------------------------
// Sobel Filter
//-------------------------------------------------------------------------------------------------
float4 SobelFilter(sampler2D image, float2 pixelLength, float2 texCoord)
{
    float4 sumHorizontal = float4(0, 0, 0, 1);
    float4 sumVertical = float4(0, 0, 0, 1);
    float2 coordinate;
    int count = 0; //x, y から求めるより結果的に演算数が減る

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            coordinate = float2(texCoord.x + pixelLength.x * x, texCoord.y + pixelLength.y * y);
            sumHorizontal.rgb += tex2D(image, coordinate).rgb * SobelHorizontalFilter[count];
            sumVertical.rgb += tex2D(image, coordinate).rgb * SobelVerticalFilter[count];
            count++;
        }
    }

    float4 color = float4(0, 0, 0, 1);

    color.rgb = sqrt(sumHorizontal * sumHorizontal + sumVertical * sumVertical);

    return color;
}

//-------------------------------------------------------------------------------------------------
// Moving Average Filter
//-------------------------------------------------------------------------------------------------
float4 MovingAverageFilter
    (sampler2D image, int halfFilterSizePx, float2 pixelLength, float2 inputPos)
{
    float4 color = float4(0, 0, 0, 1);
    float2 coordinate;

    for (int x = -halfFilterSizePx; x <= halfFilterSizePx; x++)
    {
        for (int y = -halfFilterSizePx; y <= halfFilterSizePx; y++)
        {
            color.rgb += tex2D(image, float2(inputPos.x + pixelLength.x * x,
                                             inputPos.y + pixelLength.y * y)).rgb;
        }
    }

    int filterWidthPx = halfFilterSizePx * 2 + 1;

    color.rgb /= filterWidthPx * filterWidthPx;

    return color;
}

//-------------------------------------------------------------------------------------------------
// SymmetricNearestNeighbor Filter
//-------------------------------------------------------------------------------------------------
float4 CalcSymmetricNearestNeighborColor
    (sampler2D image, float4 centerColor, float2 inputPos, float2 offset)
{
    float4	color0 = tex2D(image, inputPos + offset);
    float4	color1 = tex2D(image, inputPos - offset);
    float3	d0 = color0.rgb - centerColor.rgb;
    float3	d1 = color1.rgb - centerColor.rgb;

    if (dot(d0, d0) < dot(d1, d1))
    {
        return color0;
    }

    return color1;
}

//-------------------------------------------------------------------------------------------------
// SymmetricNearestNeighbor Filter
//-------------------------------------------------------------------------------------------------
float4 SymmetricNearestNeighborFilter
    (sampler2D image, int halfFilterSizePx, float2 pixelLength, float2 inputPos)
{
    // 実際には右側～下半分の座標を参照した結果も注視点に反映されますが、
    // SymmetricNearestNeighborFilter は点対称に値を比較するため、
    // 上半分の算出結果と下半分の算出結果は等しくなります。
    // したがって走査するのはフィルタサイズの半分で十分で、
    // その結果を 2 倍すればすべてのピクセルを参照した結果に等しくなります。

    // 除算はコストが大きいので CPU で事前計算して渡した方が高速になります。

    float pixels = 1.0f;
    float4 centerColor = tex2D(image, inputPos);
    float4 outputColor = centerColor;

    // 注視点の上半分の算出

    for (int y = -halfFilterSizePx; y < 0; y++)
    {
        float offsetY = y * pixelLength.y;

        for (int x = -halfFilterSizePx; x <= halfFilterSizePx; x++)
        {
            float2 offset = float2(x * pixelLength.x, offsetY);

            outputColor += CalcSymmetricNearestNeighborColor
                (image, centerColor, inputPos, offset) * 2.0f;

            pixels += 2.0f;
        }
    }

    // Y = 0 のとき、丁度注視点までの算出

    for (int x = -halfFilterSizePx; x < 0; x++)
    {
        float2 offset = float2(x * pixelLength.x, 0.0f);

        outputColor += CalcSymmetricNearestNeighborColor
            (image, centerColor, inputPos, offset) * 2.0f;

        pixels += 2.0f;
    }

    outputColor /= pixels;

    return outputColor;
}

#endif //XJSHADERLIBRARY_IMAGEFILTER_INCLUDED