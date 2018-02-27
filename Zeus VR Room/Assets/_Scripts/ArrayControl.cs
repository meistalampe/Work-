using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArrayControl : MonoBehaviour {

    AudioSource[] audioSource;
    public Int32[] active;

    public GameObject scriptObject; UnityServer getActive;
    // Use this for initialization

    void Awake()
    {
        getActive = scriptObject.GetComponent<UnityServer>();
    }

    void Start()
    {
        audioSource = GetComponentsInChildren<AudioSource>();
        active = new int[8];
      
    }
        // Update is called once per frame
        void Update ()
    {
        for (int i = 0; i < 8; i++)
        {
            active[i] = getActive.active[i];
            //Debug.Log(getActive.active[i]);
            if (active[i] == 1)
            {
                audioSource[i].mute = false;
               
            }
            else
            {
                audioSource[i].mute = true;
            }
        }

       
	}
}
