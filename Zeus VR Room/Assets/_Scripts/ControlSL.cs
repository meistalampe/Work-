using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlSL : MonoBehaviour {
    public Light spot;
    public GameObject scriptObject; NetworkSetup input; 
 
    public Color white = new Color(1.0f, 1.0f, 1.0f, 1.0f);
    public Color green = new Color(0.0f, 1.0f, 0.0f, 1.0f);
    public Color blue = new Color(0.0f, 0.0f, 1.0f, 1.0f);
    public Color red = new Color(1.0f, 0.0f, 0.0f, 1.0f);
    // Use this for initialization
    void Start ()
    {
        input = scriptObject.GetComponent<NetworkSetup>();
        spot = GetComponent<Light>();
        
	}
	
	// Update is called once per frame
	void Update ()
    {
        
        if (input.lightEvent == true)
        {
            spot.range = 13;
            switch (input.lightColor)
            {
                case 0:
                    spot.color = white;
                    spot.enabled = false;
                    
                    break;
                case 1:
                    spot.color = green;
                    spot.enabled = true;
                    break;
                case 2:
                    spot.color = blue;
                    spot.enabled = true;
                    break;
                case 3:
                    spot.color = red;
                    spot.enabled = true;
                    break;
            }
                         
        }
        else
        {
            switch (input.lightColor)
            {
                case 0:
                    spot.color = white;
                    spot.enabled = true;
                    break;
                case 1:
                    spot.color = green;
                    spot.enabled = true;
                    break;
                case 2:
                    spot.color = blue;
                    spot.enabled = true;
                    break;
                case 3:
                    spot.color = red;
                    spot.enabled = true;
                    break;
            }
            
            spot.range = 13;
            spot.enabled = true;

        }
	}
}
