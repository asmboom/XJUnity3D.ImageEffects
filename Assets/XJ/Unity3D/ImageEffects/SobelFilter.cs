using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/SobelFilter")]
    public class SobelFilter : ImageEffect
    {
        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            base.Material.SetFloat("_PixelWidth", 1.0f / source.width);
            base.Material.SetFloat("_PixelHeight", 1.0f / source.height);

            base.OnRenderImage(source, destination);
        }
    }
}