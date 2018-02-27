using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorControlSkinConduct : MonoBehaviour {

    // Use this for initialization

    // Floor Position , Variables to Move the Floor
    Transform tFloorPos;
    
    public float speed;
    float step;
    float Sign = -1.0f;
    float transformY;

    float maxDepth;
    float minDepth;

    float upperBorder;
    float lowerBorder;

    public GameObject scriptObject; UnityReceive getScript;
    private void Awake()
    {
        getScript = scriptObject.GetComponent<UnityReceive>();
    }

    void Start ()
    {
        // get the current Transform of GameObject Floor
        tFloorPos = GetComponent<Transform>();
        // extract and convert the height parameter of the transform
        transformY = System.Convert.ToSingle(getScript.depth);
        // set the new pposition of the Gameobject Floor to position(x)
        // note:    due to only sending positiv values of depth transformY has to
        //          be multiplied by Sign which is -1.0 to fit the Unity Environment
        tFloorPos.position = new Vector3(0.0f, transformY * Sign, 0.0f);

        // Initializing the movementparameters such as Borders and Speed
        // speed with which the floor rises or decends
        speed = 1.0f;
        // Borders (recommendations min = 1 , max= 25-30)
        minDepth = 1.0f;
        maxDepth = 25.0f;
        // turning positiv values into usable parameters
        lowerBorder = maxDepth * Sign;
        upperBorder = minDepth * Sign;
    }
	
	// Update is called once per frame
	void Update ()
    {
        // polling the current value of depth every frame
        transformY = System.Convert.ToSingle(getScript.depth);
        // defining the size of the steps the floor will make every frame
        step = speed * Time.deltaTime;

        // movement conditions, prohibiting the floor from exceeding the set Borders
        // and adjusting the direction of the movement accordingly
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
