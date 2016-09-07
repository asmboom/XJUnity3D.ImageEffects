using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/PixelArtShader")]
    public class PixelArtShader : ImageEffect
    {
        #region Field

        public Color[] colorPallet;

        [Range(1, 50)]
        public int resolutionDivision;

        #endregion Filed

        protected override void Start()
        {
            base.Start();

            if (this.colorPallet == null || this.colorPallet.Length == 0)
            {
                this.colorPallet = new Color[]
                {
                    Color.black,
                    Color.white,
                    Color.gray
                };
            }
        }

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            base.Material.SetFloat("_PixelWidth", 1f / source.width);
            base.Material.SetFloat("_PixelHeight", 1f / source.height);

            base.Material.SetColorArray("_RgbColorPallet", this.colorPallet);
            base.Material.SetInt("_RgbColorPalletLength", this.colorPallet.Length);
            base.Material.SetInt("_ResolutionDivision", this.resolutionDivision);

            RenderTexture renderTexture = RenderTexture.GetTemporary
                (source.width / this.resolutionDivision,
                 source.height / this.resolutionDivision,
                 source.depth,
                 source.format);

            Graphics.Blit(source, renderTexture, base.Material, 0);
            Graphics.Blit(renderTexture, null, base.Material, 1);

            RenderTexture.ReleaseTemporary(renderTexture);

        }
    }
}