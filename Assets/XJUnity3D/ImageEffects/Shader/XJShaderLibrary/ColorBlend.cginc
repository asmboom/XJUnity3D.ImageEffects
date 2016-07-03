#ifndef XJSHADERLIBRARY_COLORBLEND_INCLUDED
#define XJSHADERLIBRARY_COLORBLEND_INCLUDED

#include "./CollorCollection.cginc"

float3 BlendLighten(float3 baseColor, float3 blendColor)
{
    return max(blendColor, baseColor);
}

float3 BlendLighten(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendLighten(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendDarken(float3 baseColor, float3 blendColor)
{
    return min(blendColor, baseColor);
}

float3 BlendDarken(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendDarken(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendLinearBurn(float3 baseColor, float3 blendColor)
{
    return max(baseColor + blendColor - 1.0, 0.0);
}

float3 BlendLinearBurn(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendLinearBurn(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendLinearDodge(float3 baseColor, float3 blendColor)
{
    return min(baseColor + blendColor, 1.0);
}

float3 BlendLinearDodge(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendLinearDodge(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendLinearLight(float3 baseColor, float3 blendColor)
{
    return (blendColor < 0.5) ? BlendLinearBurn(baseColor, (2.0 * blendColor)) : BlendLinearDodge(baseColor, (2.0 * (blendColor - 0.5)));
}

float3 BlendLinearLight(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendLinearLight(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendScreen(float3 baseColor, float3 blendColor)
{
    return (1.0 - ((1.0 - baseColor) * (1.0 - blendColor)));
}

float3 BlendScreen(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendScreen(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendOverLay(float3 baseColor, float3 blendColor)
{
    return (baseColor < 0.5) ? (2.0 * baseColor * blendColor) : (1.0 - 2.0 * (1.0 - baseColor) * (1.0 - blendColor));
}

float3 BlendOverLay(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendOverLay(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendSoftLight(float3 baseColor, float3 blendColor)
{
    return ((blendColor < 0.5) ? (2.0 * baseColor * blendColor + baseColor * baseColor * (1.0 - 2.0 * blendColor)) : (sqrt(baseColor) * (2.0 * blendColor - 1.0) + 2.0 * baseColor * (1.0 - blendColor)));
}

float3 BlendSoftLight(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendSoftLight(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendColorDodge(float3 baseColor, float3 blendColor)
{
    return (blendColor == 1.0) ? blendColor : min(baseColor / (1.0 - blendColor), 1.0);
}

float3 BlendColorDodge(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendColorDodge(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendColorBurn(float3 baseColor, float3 blendColor)
{
    return ((blendColor == 0.0) ? blendColor : max((1.0 - ((1.0 - baseColor) / blendColor)), 0.0));
}

float3 BlendColorBurn(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendColorBurn(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendVividLight(float3 baseColor, float3 blendColor)
{
    return ((blendColor < 0.5) ? BlendColorBurn(baseColor, (2.0 * blendColor)) : BlendColorDodge(baseColor, (2.0 * (blendColor - 0.5))));
}

float3 BlendVividLight(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendVividLight(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendPinLight(float3 baseColor, float3 blendColor)
{
    return (blendColor < 0.5) ? BlendDarken(baseColor, (2.0 * blendColor)) : BlendLighten(baseColor, (2.0 *(blendColor - 0.5)));
}

float3 BlendPinLight(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendPinLight(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendHardLerp(float3 baseColor, float3 blendColor)
{
    return ((BlendVividLight(baseColor, blendColor) < 0.5) ? 0.0 : 1.0);
}

float3 BlendHardLerp(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendHardLerp(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendReflect(float3 baseColor, float3 blendColor)
{
    return ((blendColor == 1.0) ? blendColor : min(baseColor * baseColor / (1.0 - blendColor), 1.0));
}

float3 BlendReflect(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendReflect(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendNegation(float3 baseColor, float3 blendColor)
{
    return (float3(1,1,1) - abs(float3(1,1,1) - baseColor - blendColor));
}

float3 BlendNegation(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendNegation(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendExclusion(float3 baseColor, float3 blendColor)
{
    return (baseColor + blendColor - 2.0 * baseColor * blendColor);
}

float3 BlendExclusion(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendExclusion(baseColor, blendColor.rgb),blendColor.a);
}

float3 BlendPhoenix(float3 baseColor, float3 blendColor)
{
    return (min(baseColor, blendColor) - max(baseColor, blendColor) + float3(1,1,1));
}

float3 BlendPhoenix(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendPhoenix(baseColor, blendColor.rgb),blendColor.a);
}

// Hue Blend mode creates the result color by combining the luminance and saturation of the baseColor color with the hue of the blendColor color.
float3 BlendHue(float3 baseColor, float3 blendColor)
{
    float3 baseHSL = RgbToHsl(baseColor);
    return HslToRgb(float3(RgbToHsl(blendColor).r, baseHSL.g, baseHSL.b));
}

float3 BlendHue(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendHue(baseColor, blendColor.rgb),blendColor.a);
}

// Saturation Blend mode creates the result color by combining the luminance and hue of the base color with the saturation of the blendColor color.
float3 BlendSaturation(float3 baseColor, float3 blendColor)
{
    float3 baseHSL = RgbToHsl(baseColor);
    return HslToRgb(float3(baseHSL.r, RgbToHsl(blendColor).g, baseHSL.b));
}

float3 BlendSaturation(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendSaturation(baseColor, blendColor.rgb),blendColor.a);
}

// Color Mode keeps the brightness of the base color and applies both the hue and saturation of the blendColor color.
float3 BlendColor(float3 baseColor, float3 blendColor)
{
    float3 blendHSL = RgbToHsl(blendColor);
    return HslToRgb(float3(blendHSL.r, blendHSL.g, RgbToHsl(baseColor).b));
}

float3 BlendColor(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendColor(baseColor, blendColor.rgb),blendColor.a);
}

// Luminosity Blend mode creates the result color by combining the hue and saturation of the base color with the luminance of the blend color.
float3 BlendLuminosity(float3 baseColor, float3 blendColor)
{
    float3 baseHSL = RgbToHsl(baseColor);
    return HslToRgb(float3(baseHSL.r, baseHSL.g, RgbToHsl(blendColor).b));
}

float3 BlendLuminosity(float3 baseColor, float4 blendColor)
{
    return lerp(baseColor, BlendLuminosity(baseColor, blendColor.rgb),blendColor.a);
}

#define GammaCorrection(color, gamma) pow(color, 1.0 / gamma)
#define LevelsControlInputRange(color, minInput, maxInput)  min(max(color - float3(minInput,minInput,minInput), float3(0,0,0)) / (float3(maxInput,maxInput,maxInput) - float3(minInput,minInput,minInput)), float3(1,1,1))
#define LevelsControlInput(color, minInput, gamma, maxInput) GammaCorrection(LevelsControlInputRange(color, minInput, maxInput), gamma)
#define LevelsControlOutputRange(color, minOutput, maxOutput) lerp(float3(minOutput,minOutput,minOutput), float3(maxOutput,maxOutput,maxOutput), color)
#define LevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput)     LevelsControlOutputRange(LevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)

#endif //XJSHADERLIBRARY_COLORBLEND_INCLUDED