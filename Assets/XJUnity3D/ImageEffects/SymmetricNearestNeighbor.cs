using UnityEngine;

namespace XJUnity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/SymmetricNearestNeighbor")]
    public class SymmetricNearestNeighbor : ImageEffect
    {
        [Range(1, 50)]
        public int filterSizePx = 5;

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material.SetInt("_ImageWidth", source.width);
            Material.SetInt("_ImageHeight", source.height);
            Material.SetInt("_FilterSizePx", this.filterSizePx);

            base.OnRenderImage(source, destination);
        }
    }
}