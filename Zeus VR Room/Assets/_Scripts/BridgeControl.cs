using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BridgeControl : MonoBehaviour {

    // Use this for initialization
    public GameObject Object;
    public Transform transformBridge;
    private float scaleX;
    public int width;

    public GameObject scriptObject; NetworkSetup getData;

    void Awake()
    {
        getData = scriptObject.GetComponent<NetworkSetup>();
        transformBridge = GetComponent<Transform>();
        Object = GameObject.Find("Bridge");
    }
    void Start ()
    {
        width = 1;
    }
	
	// Update is called once per frame
	void Update ()
    {
        width = getData.bridgeWidth;

        switch(width)
        {
            case 0:
                scaleX = 0.25f;
                break;
            case 1:
                scaleX = 0.5f;
                break;
            case 2:
                scaleX = 0.75f;
                break;
            case 3:
                scaleX = 1.0f;
                break;
        }
        
        Object.gameObject.transform.localScale = new Vector3(scaleX, 0.06f, 2.848656f);
    }
}
