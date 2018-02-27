using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorControl : MonoBehaviour
{
    // Use this for initialization
    // Floor Position , Variables to Move the Floor
    private Transform tFloorPos;
    private float step;
    public float speed;
    private float Sign = -1.0f;
    private float transformY;

    //[HideInInspector]
    public float maxDepth;
    //[HideInInspector]
    public float minDepth;

    public float fDepth;

    float upperBorder;
    float lowerBorder;

    public GameObject scriptObject; UnityServer getDepth;

    void Awake()
    {
        getDepth = scriptObject.GetComponent<UnityServer>();
    }

    void Start()
    {
        tFloorPos = GetComponent<Transform>();
        transformY = System.Convert.ToSingle(getDepth.depth);
        tFloorPos.position = new Vector3(0.0f, transformY*Sign, 0.0f);

        speed = 1.0f;
        minDepth = 1.0f;
        maxDepth = 20.0f;
        lowerBorder = maxDepth * Sign;
        upperBorder = minDepth * Sign;
    }

    // Update is called once per frame
    void Update()
    {

        //if (Input.GetKey(KeyCode.UpArrow) && tFloorPos.position.y < -1.00f)
        //    tFloorPos.position += Vector3.up * Time.deltaTime * 5;
        //if (Input.GetKey(KeyCode.DownArrow) && tFloorPos.position.y > -10.00f)
        //    tFloorPos.position -= Vector3.up * Time.deltaTime * 5;

        transformY = System.Convert.ToSingle(getDepth.depth);
        step = speed * Time.deltaTime;

        if (transformY * Sign >= lowerBorder && transformY * Sign <= upperBorder)
        {          
            tFloorPos.position = Vector3.MoveTowards(tFloorPos.position, new Vector3(0.0f, (transformY * Sign), 0.0f), step);
        }
        else
        {
            tFloorPos.position = Vector3.MoveTowards(tFloorPos.position, new Vector3(0.0f, -1.0f, 0.0f), step);
        }





    }

}   


           