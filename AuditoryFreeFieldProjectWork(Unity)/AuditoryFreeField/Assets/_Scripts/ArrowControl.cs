using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ArrowControl : MonoBehaviour {

    // Use this for initialization

    public GameObject scriptObject; ArrayControl getArrowRot;
    public Transform arrowTransform;
    public float arrowRotX;
    Quaternion target;


    private void Awake()
    {
        getArrowRot = scriptObject.GetComponent<ArrayControl>();
        Quaternion target = Quaternion.Euler(0.0f, 0.0f, -90.0f);
        arrowTransform.rotation = target;
        //arrowTransform.rotation = Quaternion.AngleAxis(-180.0f, Vector3.up);
    }
    void Start ()
    {
        arrowTransform = GetComponent<Transform>();         
    }
	
	// Update is called once per frame
	void Update ()
    {
        arrowRotX = getArrowRot.rotX;
        target = Quaternion.Euler(arrowRotX, 0.0f, -90.0f);
        //arrowTransform.rotation = Quaternion.AngleAxis(arrowRotX, Vector3.up);
        arrowTransform.rotation = target;

    }
}

