// filename: ArrowControl.cs
// Saarland University of Applied Sciences
// author: Dominik Limbach
// date: 01.11.2017

// description: program will receive rotation information and apply it to the arrow

using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ArrowControl : MonoBehaviour {

    public GameObject scriptObject; ArrayControl getArrowRot;
    public Transform arrowTransform;
    public float arrowRotX;
    Quaternion target;

    private void Awake()
    {
        getArrowRot = scriptObject.GetComponent<ArrayControl>();
        Quaternion target = Quaternion.Euler(0.0f, 0.0f, -90.0f);
        arrowTransform.rotation = target;
    }
    void Start ()
    {
        arrowTransform = GetComponent<Transform>();         
    }

	void Update ()
    {
        arrowRotX = getArrowRot.rotX;
        target = Quaternion.Euler(arrowRotX, 0.0f, -90.0f);
        arrowTransform.rotation = target;
    }
}

