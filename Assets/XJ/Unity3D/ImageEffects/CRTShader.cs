using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/CRTShader")]
    public class CRTShader : ImageEffect
    {
        // 四隅の陰りを無効にするには、edgeShadowStrength を 0 にします。
        // 光の反射を無効にするには、reflectionLightColor を 0 にします。

        public enum CRTType
        {
            ApertureGrill = 0,
            ShadowMask = 1
        }

        public CRTType crtType = CRTType.ApertureGrill;
        public bool enalbeBarrelDistortion;

        public Texture2D ghostTex;
        public float ghostStrength;

        public bool enableAutoGhostImage = false;
        public float autoGhostImageRefreshTimeSec = 0.2f;
        private float autoGhostImagePastTimeSec = 0;

        public float noiseStrength;

        [Range(0, 10)]
        public float edgeShadowStrength;

        public Vector3 reflectionLightPosition = new Vector3(0, 1.2f, 1);
        public Vector4 reflectionLightColor = new Vector4(1, 1, 1, 1);

        public Texture2D glareTex;
        public float glareStrength;

        void OnPostRender()
        {
            UpdateAutoGhostImage();
        }

        private void UpdateAutoGhostImage()
        {
            if (!this.enableAutoGhostImage)
            {
                return;
            }

            if (this.autoGhostImagePastTimeSec < this.autoGhostImageRefreshTimeSec)
            {
                this.autoGhostImagePastTimeSec += Time.deltaTime;
                return;
            }

            this.autoGhostImagePastTimeSec = 0;

            DestroyImmediate(this.ghostTex);

            this.ghostTex = new Texture2D
                (Screen.width, Screen.height, TextureFormat.ARGB32, false);
            this.ghostTex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
            this.ghostTex.Apply();
        }

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material.SetFloat("_ImageWidth", source.width);
            Material.SetFloat("_ImageHeight", source.height);

            Material.SetFloat("_PixelWidth", 1f / source.width);
            Material.SetFloat("_PixelHeight", 1f / source.height);

            Material.SetInt("_ShadowMaskType", (int)this.crtType);
            Material.SetInt("_EnableBarrelDistortion", this.enalbeBarrelDistortion ? 1 : 0);
            Material.SetTexture("_GhostTex", this.ghostTex);
            Material.SetFloat("_GhostStrength", this.ghostStrength);
            Material.SetFloat("_NoiseStrength", this.noiseStrength);
            Material.SetFloat("_EdgeShadowStrength", this.edgeShadowStrength);
            Material.SetVector("_ReflectionLightPosition", this.reflectionLightPosition);
            Material.SetVector("_ReflectionLightColor", this.reflectionLightColor);
            Material.SetTexture("_GlareTex", this.glareTex);
            Material.SetFloat("_GlareStrength", this.glareStrength);

            base.OnRenderImage(source, destination);
        }
    }
}