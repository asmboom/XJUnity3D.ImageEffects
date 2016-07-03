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
            // (field) material ではなく (property) Material である点に注意します。
            // もし material を指定すると、継承クラスで Material が一度も参照されないとき、
            // material は null になります。その結果 Graphics.Bilt に失敗します。

            Graphics.Blit(source, destination, Material);
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