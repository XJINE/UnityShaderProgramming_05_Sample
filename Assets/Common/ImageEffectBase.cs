using UnityEngine;

[ExecuteAlways, RequireComponent(typeof(Camera))]
public class ImageEffectBase : MonoBehaviour
{
    public Material material;

    protected virtual void Start()
    {
        enabled = material && material.shader.isSupported;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, this.material);
    }
}