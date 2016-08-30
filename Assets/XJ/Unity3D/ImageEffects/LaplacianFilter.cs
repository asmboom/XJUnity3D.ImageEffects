using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/LaplacianFilterFilter")]
    public class LaplacianFilter : ImageEffect
    {

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material.SetFloat("_PixelLengthWidth", 1.0f / source.width);
            Material.SetFloat("_PixelLengthHeight", 1.0f / source.height);

            base.OnRenderImage(source, destination);
        }
    }
}