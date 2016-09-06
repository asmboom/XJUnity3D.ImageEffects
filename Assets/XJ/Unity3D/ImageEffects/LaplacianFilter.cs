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
            Material.SetFloat("_PixelWidth", 1.0f / source.width);
            Material.SetFloat("_PixelHeight", 1.0f / source.height);

            base.OnRenderImage(source, destination);
        }
    }
}