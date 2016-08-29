﻿using UnityEngine;

namespace XJ.Unity3D.ImageEffects
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("XJImageEffects/MovingAverageFilter")]
    public class MovingAverageFilter : ImageEffect
    {
        [Range(0, 50)]
        public int halfFilterSizePx = 2;

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material.SetFloat("_PixelLengthWidth", 1.0f / source.width);
            Material.SetFloat("_PixelLengthHeight", 1.0f / source.height);
            Material.SetInt("_HalfFilterSizePx", this.halfFilterSizePx);

            base.OnRenderImage(source, destination);
        }
    }
}