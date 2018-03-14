using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorStart : MonoBehaviour {
    public Transform transformFloor;
    private float step;
    public float speed;
    private float transformZ;
    public int position;

    public GameObject scriptObject; NetworkSetup getData;

    // Use this for initialization

    void Awake()
    {
        getData = scriptObject.GetComponent<NetworkSetup>();
        transformFloor = GetComponent<Transform>();
    }
    void Start ()
    {
        speed = getData.speedDefault;
        transformZ = 0.0f;
        transformFloor.position = new Vector3(0.014f, 0.0f, transformZ);
        position = 0;
    }
	
	// Update is called once per frame
	void Update ()
    {
        speed = getData.speedDefault;
        step = speed * Time.deltaTime;
        position = getData.targetPositionFloor;

        if (getData.openFloorSequence == true)
        {
            switch(position)
            { 
                case 0: // closed
                transformZ = 0.0f;
                break;
                case 1: // 1/3 open
                transformZ = -1.6f;
                break;
                case 2: // 2/3 open
                transformZ = -3.2f;
                break;
                case 3: // open
                transformZ = -4.8f;
                break;
            }

            transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.014f, 0.0f , transformZ), step);
        }
        else
        {
            position = 0;
            transformZ = 0.0f;
            transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.014f, 0.0f, transformZ), step);
        }
	}
}
