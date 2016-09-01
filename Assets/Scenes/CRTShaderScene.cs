using UnityEngine;
using System.Collections;

public class CRTShaderScene : MonoBehaviour
{
    public GameObject upsideDownObject;

    void Start ()
    {
    }

    void Update ()
    {
        this.upsideDownObject.transform.position
            = new Vector3(this.upsideDownObject.transform.position.x,
                          Mathf.PingPong(Time.time * 2, 1.5f),
                          this.upsideDownObject.transform.position.z);
    }
}