using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SourceLocation : MonoBehaviour {

    private Vector3 asStartLocation;
    private Transform asCurrentLocation;
    private Vector3[] asPositions;
    public int choosePosition;

    // Use this for initialization
    void Start()
    {
        asStartLocation = new Vector3(0.0f, 1.0f, 0.0f);
        asCurrentLocation = GetComponent<Transform>();
        //Debug.Log(currentLocation.position);

        asPositions = new Vector3[10];

        asPositions[0] = new Vector3(0.0f, 1.0f, 0.0f);
        asPositions[1] = new Vector3(-1.0f, 1.0f, 1.0f);
        asPositions[2] = new Vector3(0.0f, 1.0f, 1.0f);
        asPositions[3] = new Vector3(1.0f, 1.0f, 1.0f);
        asPositions[4] = new Vector3(-1.0f, 1.0f, 0.0f);
        asPositions[5] = new Vector3(0.0f, 1.0f, 0.0f);
        asPositions[6] = new Vector3(1.0f, 1.0f, 0.0f);
        asPositions[7] = new Vector3(-1.0f, 1.0f, -1.0f);
        asPositions[8] = new Vector3(0.0f, 1.0f, -1.0f);
        asPositions[9] = new Vector3(1.0f, 1.0f, -1.0f);


    }

    // Update is called once per frame
    void Update()
    {

        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            choosePosition = 0;
        }
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            choosePosition = 1;
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            choosePosition = 2;
        }
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            choosePosition = 3;
        }
        if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            choosePosition = 4;
        }
        if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            choosePosition = 5;
        }
        if (Input.GetKeyDown(KeyCode.Alpha6))
        {
            choosePosition = 6;
        }
        if (Input.GetKeyDown(KeyCode.Alpha7))
        {
            choosePosition = 7;
        }
        if (Input.GetKeyDown(KeyCode.Alpha8))
        {
            choosePosition = 8;
        }
        if (Input.GetKeyDown(KeyCode.Alpha9))
        {
            choosePosition = 9;
        }

        asCurrentLocation.position = asPositions[choosePosition];


    }
}
