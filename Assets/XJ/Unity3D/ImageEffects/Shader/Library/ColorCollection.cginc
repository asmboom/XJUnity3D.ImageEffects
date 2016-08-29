#ifndef XJSHADERLIBRARY_COLORCOLLECTION_INCLUDED
#define XJSHADERLIBRARY_COLORCOLLECTION_INCLUDED

/*
** Copyright (c) 2012, Romain Dura romain@shazbits.com
**
** Permission to use, copy, modify, and/or distribute this software for any
** purpose with or without fee is hereby granted, provided that the above
** copyright notice and this permission notice appear in all copies.
**
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
** WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
** SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
** WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
** ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
** IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

float3 RgbToHsv(float3 rgbColor)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(rgbColor.bg, K.wz), float4(rgbColor.gb, K.xy), step(rgbColor.b, rgbColor.g));
    float4 q = lerp(float4(p.xyw, rgbColor.r), float4(rgbColor.r, p.yzx), step(p.x, rgbColor.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;

    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 HsvToRgb(float3 rgbColor)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(rgbColor.xxx + K.xyz) * 6.0 - K.www);

    return rgbColor.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), rgbColor.y);
}

float3 RgbToHsl(float3 rgbColor)
{
    float3 hsl;

    float fmin = min(min(rgbColor.r, rgbColor.g), rgbColor.b);
    float fmax = max(max(rgbColor.r, rgbColor.g), rgbColor.b);
    float delta = fmax - fmin;

    hsl.z = (fmax + fmin) / 2.0;

    if (delta == 0.0)
    {
        hsl.x = 0.0;
        hsl.y = 0.0;
    }
    else
    {
        if (hsl.z < 0.5)
        {
            hsl.y = delta / (fmax + fmin);
        }
        else
        {
            hsl.y = delta / (2.0 - fmax - fmin);
        }

        float deltaR = (((fmax - rgbColor.r) / 6.0) + (delta / 2.0)) / delta;
        float deltaG = (((fmax - rgbColor.g) / 6.0) + (delta / 2.0)) / delta;
        float deltaB = (((fmax - rgbColor.b) / 6.0) + (delta / 2.0)) / delta;

        if (rgbColor.r == fmax)
        {
            hsl.x = deltaB - deltaG;
        }
        else if (rgbColor.g == fmax)
        {
            hsl.x = (1.0 / 3.0) + deltaR - deltaB;
        }
        else if (rgbColor.b == fmax)
        {
            hsl.x = (2.0 / 3.0) + deltaG - deltaR;
        }

        if (hsl.x < 0.0)
        {
            hsl.x += 1.0;
        }
        else if (hsl.x > 1.0)
        {
            hsl.x -= 1.0;
        }
    }

    return hsl;
}

float HueToRGB(float f1, float f2, float hue)
{
    if (hue < 0.0)
    {
        hue += 1.0;
    }
    else if (hue > 1.0)
    {
        hue -= 1.0;
    }

    float res;

    if ((6.0 * hue) < 1.0)
    {
        res = f1 + (f2 - f1) * 6.0 * hue;
    }
    else if ((2.0 * hue) < 1.0)
    {
        res = f2;
    }
    else if ((3.0 * hue) < 2.0)
    {
        res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
    }
    else
    {
        res = f1;
    }

    return res;
}

float3 HslToRgb(float3 hsl)
{
    float3 rgb;

    if (hsl.y == 0.0)
    {
        rgb = float3(hsl.z, hsl.z, hsl.z);
    }
    else
    {
        float f2;

        if (hsl.z < 0.5)
        {
            f2 = hsl.z * (1.0 + hsl.y);
        }
        else
        {
            f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
        }

        float f1 = 2.0 * hsl.z - f2;

        rgb.r = HueToRGB(f1, f2, hsl.x + (1.0 / 3.0));
        rgb.g = HueToRGB(f1, f2, hsl.x);
        rgb.b = HueToRGB(f1, f2, hsl.x - (1.0 / 3.0));
    }

    return rgb;
}

float3 HslShift(float3 baseColor, float3 shift)
{
    float3 hsl = RgbToHsl(baseColor);
    hsl = hsl + shift.xyz;
    hsl.yz = saturate(hsl.yz);

    return HslToRgb(hsl);
}

float3 HslShift(float3 baseColor, float4 shift)
{
    return lerp(baseColor, HslShift(baseColor, shift.rgb), shift.a);
}

float3 HsvShift(float3 baseColor, float3 shift)
{
    float3 hsv = RgbToHsv(baseColor);
    hsv = hsv + shift.xyz;
    hsv.yz = saturate(hsv.yz);

    return HsvToRgb(hsv);
}

float3 HsvShift(float3 baseColor, float4 shift)
{
    return lerp(baseColor, HsvShift(baseColor, shift.rgb), shift.a);
}

float4 Desaturate(float3 color, float Desaturation)
{
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    float d = dot(grayXfer, color);
    float3 gray = float3(d, d, d);
    return float4(lerp(color, gray, Desaturation), 1.0);
}

/*
** Contrast, saturation, brightness
** Code of this function is from TGM's shader pack
** http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=21057
*/

// For all settings: 1.0 = 100% 0.5=50% 1.5 = 150%
float3 ContrastSaturationBrightness(float3 color, float brt, float sat, float con)
{
    // Increase or decrease theese values to adjust r, g and b color channels seperately
    const float AvgLumR = 0.5;
    const float AvgLumG = 0.5;
    const float AvgLumB = 0.5;

    const float3 LumCoeff = float3(0.2125, 0.7154, 0.0721);

    float3 AvgLumin = float3(AvgLumR, AvgLumG, AvgLumB);
    float3 brtColor = color * brt;
    float d = dot(brtColor, LumCoeff);
    float3 intensity = float3(d, d, d);
    float3 satColor = lerp(intensity, brtColor, sat);
    float3 conColor = lerp(AvgLumin, satColor, con);

    return conColor;
}

float4 RgbToGray(float4 rgbColor)
{
    float gray = (rgbColor.r + rgbColor.g + rgbColor.r) / 3;
    return float4(gray, gray, gray, rgbColor.a);
}

#endif //XJSHADERLIBRARY_COLORCOLLECTION_INCLUDED