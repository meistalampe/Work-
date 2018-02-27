using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlPLPit : MonoBehaviour {


    public Light point;
    public GameObject scriptObject; NetworkSetup input; ControlVR gd;
    private Transform pitlightTransform;

    public Color white = new Color(1.0f, 1.0f, 1.0f, 1.0f);
    public Color green = new Color(0.0f, 1.0f, 0.0f, 1.0f);
    public Color blue = new Color(0.0f, 0.0f, 1.0f, 1.0f);
    public Color red = new Color(1.0f, 0.0f, 0.0f, 1.0f);

    

    // Use this for initialization

    void Start()
    {
        input = scriptObject.GetComponent<NetworkSetup>();
        gd = scriptObject.GetComponent<ControlVR>();
        pitlightTransform = GetComponent<Transform>();
       
        point = GetComponent<Light>();
    }

    // Update is called once per frame
    void Update()
    {
        if(gd.depth >= (pitlightTransform.position.y - 2.0f))
        {
            point.enabled = false;
        }
        else
        {
            point.enabled = true;
        }

        if(input.lightEvent == false)
        {
            point.intensity = 2.0f;
        }
        else
        {           
            point.intensity = 50.0f;
           
        }

            switch (input.lightColor)
            {
                case 0:
                    point.color = white;

                    break;
                case 1:
                    point.color = green;
                    
                    break;
                case 2:
                    point.color = blue;
                    
                    break;
                case 3:
                    point.color = red;
                    
                    break;
            }
        
    }
}


