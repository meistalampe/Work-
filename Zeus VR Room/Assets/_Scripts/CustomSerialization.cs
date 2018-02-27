using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomSerialization : MonoBehaviour
{

    //private void OnSerializeNetworkView(BitStream stream, NetworkMessageInfo info)
    //{
    //    if(stream.isWriting)
    //    {
    //        Vector3 pos = transform.position;
    //        stream.Serialize(ref pos);
    //    }
    //    else
    //    {
    //        Vector3 pos = Vector3.zero;

    //        stream.Serialize(ref pos);
    //        transform.position = pos;
    //    }

    //}
    public NetworkView nView;
    private Transform pos;

    void Start()
    {
        nView = GetComponent<NetworkView>();
        pos = GetComponent<Transform>();
        
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.UpArrow) && pos.position.y < -1.0f)
        {
            
#pragma warning disable CS0618 // Type or member is obsolete
            nView.RPC("MoveUp", RPCMode.All, new object[] { 1.2f });
#pragma warning restore CS0618 // Type or member is obsolete
        }
        if (Input.GetKey(KeyCode.DownArrow) && pos.position.y > -10.0f)
        {
            
#pragma warning disable CS0618 // Type or member is obsolete
            nView.RPC("MoveDown", RPCMode.All, new object[] { 1.2f });
#pragma warning restore CS0618 // Type or member is obsolete
        }
    }

#pragma warning disable CS0618 // Type or member is obsolete
    [RPC]
#pragma warning restore CS0618 // Type or member is obsolete
    void MoveUp(float speed)
    {
        pos.position += Vector3.up * Time.deltaTime * speed;
    }
#pragma warning disable CS0618 // Type or member is obsolete
    [RPC]
#pragma warning restore CS0618 // Type or member is obsolete
    public void MoveDown(float speed)
    {
        pos.position -= Vector3.up * Time.deltaTime * speed;

    }

}
