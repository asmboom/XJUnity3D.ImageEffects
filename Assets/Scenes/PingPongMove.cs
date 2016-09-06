using UnityEngine;

public class PingPongMove : MonoBehaviour
{
    void Update ()
    {
        base.transform.position = new Vector3(base.transform.position.x,
                                              Mathf.PingPong(Time.time * 2, 1.5f),
                                              base.transform.position.z);
    }
}