using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/SobelFilter")]
    public class DotTypeDitheringFilter : ImageEffect
    {
        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material.SetFloat("_ImageSizeWidth", source.width);
            Material.SetFloat("_ImageSizeHeight", source.height);
            base.OnRenderImage(source, destination);
        }
    }
}