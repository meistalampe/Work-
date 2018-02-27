using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorStart : MonoBehaviour {
    public Transform transformFloor;
    private float step;
    public float speed;
    private float transformZ;

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
    }
	
	// Update is called once per frame
	void Update ()
    {
        speed = getData.speedDefault;
        step = speed * Time.deltaTime;

        if (getData.introSequence == true)
        {
            transformZ = 4.8f;
            transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.014f, 0.0f , transformZ), step);
        }
        else
        {
            transformZ = 0.0f;
            transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.014f, 0.0f, transformZ), step);
        }
	}
}
