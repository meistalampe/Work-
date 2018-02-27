using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ConrolPL : MonoBehaviour {
    public Light point;
    public GameObject scriptObject; NetworkSetup input;

    public Color white = new Color(1.0f, 1.0f, 1.0f, 1.0f);
    public Color green = new Color(0.0f, 1.0f, 0.0f, 1.0f);
    public Color blue = new Color(0.0f, 0.0f, 1.0f, 1.0f);
    public Color red = new Color(1.0f, 0.0f, 0.0f, 1.0f);


    // Use this for initialization
    void Start ()
    {
        input = scriptObject.GetComponent<NetworkSetup>();
        point = GetComponent<Light>();
    }
	
	// Update is called once per frame
	void Update ()
    {
		if (input.lightEvent == true)
        {
            point.enabled = false;
        }
        else
        {
            point.enabled = true;
            switch (input.lightColor)
            {
                case 0:
                    point.color = white;
                    point.enabled = true;

                    break;
                case 1:
                    point.color = green;
                    point.enabled = true;
                    break;
                case 2:
                    point.color = blue;
                    point.enabled = true;
                    break;
                case 3:
                    point.color = red;
                    point.enabled = true;
                    break;
            }
        }
	}
}
