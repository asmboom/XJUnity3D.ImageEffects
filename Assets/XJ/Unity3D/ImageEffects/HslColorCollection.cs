using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/HslColorCollection")]
    public class HslColorCollection : ImageEffect
    {
        public Vector4 hslColorShift = Vector4.zero;

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            base.Material.SetVector("_HslColorShift", this.hslColorShift);
            base.OnRenderImage(source, destination);
        }
    }
}