#ifndef XJSHADERLIBRARY_IMAGEFILTER_INCLUDED
#define XJSHADERLIBRARY_IMAGEFILTER_INCLUDED

float4 CalcSymmetricNearestNeighborColor(sampler2D image, float4 centerColor, float2 inputPosPxRatio, float2 offsetPxRatio)
{
    float4	color0 = tex2D(image, inputPosPxRatio + offsetPxRatio);
    float4	color1 = tex2D(image, inputPosPxRatio - offsetPxRatio);
    float3	d0 = color0.rgb - centerColor.rgb;
    float3	d1 = color1.rgb - centerColor.rgb;

    if (dot(d0, d0) < dot(d1, d1))
    {
        return color0;
    }

    return color1;
}

float4 SymmetricNearestNeighborFilter(sampler2D image, int2 imageSizePx, float2 inputPosPxRatio, int filterSizePx)
{
    // 実際には右側～下半分の座標を参照した結果も注視点に反映されますが、
    // SymmetricNearestNeighborFilter は点対称に値を比較するため、
    // 上半分の算出結果と下半分の算出結果は等しくなります。
    // したがって走査するのはフィルタサイズの半分で十分で、
    // その結果を 2 倍すればすべてのピクセルを参照した結果に等しくなります。

    int halfFilterWidth = filterSizePx / 2;
    float2 pixelRatio = (1.0 / imageSizePx);
    float pixels = 1.0f;
    float4 centerColor = tex2D(image, inputPosPxRatio);
    float4 outputColor = centerColor;

    // 注視点の上半分の算出

    for (int y = -halfFilterWidth; y < 0; y++)
    {
        float offsetY = y * pixelRatio.y;

        for (int x = -halfFilterWidth; x <= halfFilterWidth; x++)
        {
            float2 offset = float2(x * pixelRatio.x, offsetY);

            outputColor += CalcSymmetricNearestNeighborColor
                (image, centerColor, inputPosPxRatio, offset) * 2.0f;

            pixels += 2.0f;
        }
    }

    // Y = 0 のとき、丁度注視点までの算出

    for (int x = -halfFilterWidth; x < 0; x++)
    {
        float2 offset = float2(x * pixelRatio.x, 0.0f);

        outputColor += CalcSymmetricNearestNeighborColor
            (image, centerColor, inputPosPxRatio, offset) * 2.0f;

        pixels += 2.0f;
    }

    outputColor /= pixels;

    return outputColor;
}

#endif //XJSHADERLIBRARY_IMAGEFILTER_INCLUDED