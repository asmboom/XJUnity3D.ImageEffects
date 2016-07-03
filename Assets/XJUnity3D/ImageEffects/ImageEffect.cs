using UnityEngine;

namespace XJUnity3D.ImageEffects
{
    /// <summary>
    /// ImageEffect の基底 Class です。
    /// </summary>
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/ImageEffect")]
    public class ImageEffect : MonoBehaviour
    {
        #region Field

        public Shader shader;

        private Material material;

        #endregion Field

        #region Property

        protected Material Material
        {
            get
            {
                if (this.material == null)
                {
                    this.material = new Material(this.shader);
                    this.material.hideFlags = HideFlags.HideAndDontSave;
                }

                return this.material;
            }
        }

        #endregion Property

        #region Method

        /// <summary>
        /// ゲームの開始時に一度だけ呼び出されます。
        /// </summary>
        protected virtual void Start()
        {
            if (!SystemInfo.supportsImageEffects)
            {
                enabled = false;

                return;
            }

            if (!shader || !shader.isSupported)
            {
                enabled = false;
            }
        }

        /// <summary>
        /// すべてのレンダリングが完了し、RenderTexture にレンダリングされた後に呼び出されます。
        /// </summary>
        /// <param name="source">
        /// 描画元の RenderTexture.
        /// </param>
        /// <param name="destination">
        /// 描画先の RenderTexture.
        /// </param>
        protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Graphics.Blit(source, destination, material);
        }

        /// <summary>
        /// 無効または非アクティブになったときに呼び出されます。
        /// </summary>
        protected virtual void OnDisable()
        {
            if (this.material)
            {
                DestroyImmediate(this.material);
            }
        }

        #endregion Method
    }
}