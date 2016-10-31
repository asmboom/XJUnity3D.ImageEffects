using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    /// <summary>
    /// 実行 Window の背景を透過します。
    /// エディタ上では確認することができない点に注意します。
    /// </summary>
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("XJImageEffects/TransparentWindow")]
    public class TransparentWindow : ImageEffect
    {
        #region Enum

        internal enum WindowCompositionAttribute
        {
            WCA_ACCENT_POLICY = 19
        }

        internal enum AccentState
        {
            ACCENT_DISABLED = 0,
            ACCENT_ENABLE_GRADIENT = 1,
            ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
            ACCENT_ENABLE_BLURBEHIND = 3,
            ACCENT_INVALID_STATE = 4
        }

        #endregion Enum

        #region Struct

        /// <summary>
        /// Window のフレームをクライアント領域まで広げる大きさ。
        /// DwmExtendFrameIntoClientArea メソッドで利用します。
        /// </summary>
        private struct MARGINS
        {
            public int cxLeftWidth;
            public int cxRightWidth;
            public int cyTopHeight;
            public int cyBottomHeight;
        }

        internal struct WindowCompositionAttributeData
        {
            public WindowCompositionAttribute Attribute;
            public IntPtr Data;
            public int SizeOfData;
        }

        internal struct AccentPolicy
        {
            public AccentState AccentState;
            public int AccentFlags;
            public int GradientColor;
            public int AnimationId;
        }

        #endregion Struct

        #region DLL Import

        /// <summary>
        /// WindowHandle を取得します。
        /// </summary>
        /// <returns>
        /// WindowHandl.(Window を参照するポインタ)
        /// </returns>
        [DllImport("user32.dll")]
        private static extern IntPtr GetActiveWindow();

        /// <summary>
        /// Window の特定のパラメータに新たな値を設定します。
        /// </summary>
        /// <param name="hWnd">
        /// WindowHandle.
        /// </param>
        /// <param name="nIndex">
        /// 設定する項目を示すインデックス。
        /// </param>
        /// <param name="dwNewLong">
        /// 設定する値。
        /// </param>
        /// <returns>
        /// 結果。
        /// </returns>
        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

        /// <summary>
        /// Window のフレームをクライアント領域まで拡張します。
        /// </summary>
        /// <param name="hWnd">
        /// 操作する Window.
        /// </param>
        /// <param name="margins">
        /// フレームを拡大する大きさ。
        /// </param>
        /// <returns>
        /// 結果。
        /// </returns>
        [DllImport("Dwmapi.dll")]
        private static extern uint DwmExtendFrameIntoClientArea(IntPtr hWnd, ref MARGINS margins);

        #endregion DLL Import

        #region Method

        /// <summary>
        /// 開始時に呼び出されます。
        /// </summary>
        protected override void Start()
        {
            base.Start();

           // UnityEditor 以外で実行します。
#if !UNITY_EDITOR
            {
                const int GWL_STYLE = -16;
                const uint WS_POPUP = 0x80000000;
                const uint WS_VISIBLE = 0x10000000;

                // Window Handle (Window を操作するための参照) を取得します。
                // https://msdn.microsoft.com/ja-jp/library/cc410861.aspx

                var windowHandle = GetActiveWindow();

                // 特定の Window の値を設定します。
                // 引数は (Handle, 設定する対象を示すオフセット(インデックス), 設定する値) です。
                // https://msdn.microsoft.com/ja-jp/library/cc411203.aspx
                //
                // WGL_STYLE は、ウィンドウのスタイルを示すオフセット。
                // "POP_UP" はポップアップウィンドウにする、"WS_VISIBLE" は可視ウィンドウにする。

                SetWindowLong(windowHandle, GWL_STYLE, WS_POPUP | WS_VISIBLE);

                // DwmExtendFrameIntoClientArea はウィンドウフレームに適用されている効果を、
                // そのクライアント(コンポーネント・内容)領域まで広げるための API です。
                // すなわち、透過したウィンドウフレームを設定しておき、
                // それをその内容を描画する部分にも適用するといった形式です。
                // MARGINS は広げる領域を決定するための構造体ですが、
                // -1 を指定するとクライアント領域全体に広げる仕様となっています。
                // https://msdn.microsoft.com/ja-jp/library/windows/desktop/aa969512(v=vs.85).aspx
                // https://msdn.microsoft.com/ja-jp/library/windows/desktop/bb773244(v=vs.85).aspx

                MARGINS margins = new MARGINS()
                {
                    cxLeftWidth = -1
                };

                DwmExtendFrameIntoClientArea(windowHandle, ref margins);
            }
#endif
        }

        #endregion Method
    }
}