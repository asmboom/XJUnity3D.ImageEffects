float DegreeToRadian(float degree)
{
    // 0.01744 = 3.14 / 180;
    return degree * 0.01744;
}

float RadianToDegree(float radian)
{
    //57.3248 = 180 / 3.14;
    return radian * 57.3248;
}

float GetRandomValue(float2 coordinate, int Seed)
{
    return frac(sin(dot(coordinate.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}