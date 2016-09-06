using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/PixelArtShader")]
    public class PixelArtShader : ImageEffect
    {
        void OnPostRender()
        {
        }

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material.SetFloat("_ImageWidth", source.width);
            Material.SetFloat("_ImageHeight", source.height);

            Material.SetFloat("_PixelWidth", 1f / source.width);
            Material.SetFloat("_PixelHeight", 1f / source.height);            

            base.OnRenderImage(source, destination);
        }
    }
}