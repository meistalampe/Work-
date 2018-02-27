using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class ControlVR : MonoBehaviour
{
    public Transform transformFloor;
    public float depth;
    private float step;
    public float speed;
    private float sign;
    private float transformY;
    

    //[HideInInspector]
    public float maxDepth;
    //[HideInInspector]
    public float minDepth;

    public int range;
    public int reaction;
    

    public GameObject scriptObject; NetworkSetup getData;

    void Awake()
    {   
        getData = scriptObject.GetComponent<NetworkSetup>();
        transformFloor = GetComponent<Transform>();
        sign = -1.0f;
    }

    void Start()
    {
        transformY = getData.depthDefault;
        transformFloor.position = new Vector3(0.0f, transformY * sign, 0.0f);
        depth = transformFloor.position.y;
        speed = getData.speedDefault;
        range = 0;
        


    }

    void Update()
    {
        range = getData.range;
        reaction = getData.input.reaction;
        speed = getData.input.speed;
        

        if(getData.lightEvent == true)
        {
            RenderSettings.fogDensity = 0.7f;
        }
        else
        {
            RenderSettings.fogDensity = 0.07f;
        }
        
        // setting min , max of floor movement
        switch (range)
        {
            case 0:
                minDepth = getData.ubDefault * sign;
                maxDepth = getData.lbDefault * sign;
                break;

            case 1:

                if(getData.input.upperBorder > 1.0f)
                {
                    minDepth = getData.input.upperBorder * sign;
                    
                }
                else
                {
                    minDepth = getData.ubDefault * sign;
                    
                }

                if(getData.input.lowerBorder < 30.0f)
                {
                    maxDepth = getData.input.lowerBorder * sign;
                }
                else
                {
                    maxDepth = getData.lbDefault * sign;
                }
                break;

            default:
                print("Error: range could not be adapted.");
                break;
        }
        

        switch (reaction)
        {
            case 0: // stop function, floor stays at current location
                transformFloor = GetComponent<Transform>();
                transformY = transformFloor.position.y;
                break;

            case 1: // floor will decent
                transformY = transformY - 1.0f;                
                break;

            case 2: // floor will ascend
                transformY = transformY + 1.0f;             
                break;

            case 3: // floor will move to input value
                transformY = getData.input.depth * sign;
                break;

            case 4: // abort floor closes
                transformY = getData.depthDefault * sign;
                
                break;

            default:
                print("Error: reaction could not be recognized.");
                break;
        }
        
        step = speed * Time.deltaTime; // if speed gets controlable then put speed = System.Convert.ToSingle(getData.speed);

        if (transformY >= maxDepth && transformY <= minDepth)
        {
            transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.0f, (transformY), 0.0f), step);
        }
        else
        {
            if (transformY <= maxDepth && reaction != 4)
            {
                transformY = maxDepth;
                transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.0f, transformY, 0.0f), step);
                //reaction = 0;
                //print("floor position exceeding maxDepth. Setting floor position to maxDepth.");
            }
            if (transformY >= minDepth && reaction != 4)
            {
                transformY = minDepth;
                transformFloor.position = Vector3.MoveTowards(transformFloor.position, new Vector3(0.0f, transformY, 0.0f), step);
                //reaction = 0;
                //print("floor position exceeding minDepth. Setting floor position to minDepth.");
            }


        }

        depth = transformFloor.position.y;
    }
}
