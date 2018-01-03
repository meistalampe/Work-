 // filename: ArrayControl.cs
 // Saarland University of Applied Sciences
 // author: Dominik Limbach
 // date: 01.11.2017
 
 // description: the program controls the activation of both arrow and audio sources
 // it will gather the protokoll information from the UnityServer script
 // and execute the protokoll

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArrayControl : MonoBehaviour
{
    public AudioSource[] audioSource; // The array to contain the audiosources
    public Vector3 arrowRotation; // Vector3 to control the arrow rotation
    public float rotX; // Float variable which determines the angle of rotation on the Y-axis
    public float[] angles; // Array that holds possible angles for the arrow rotation
    public AudioClip sound; // Variable to hold the SoundClip
    public Int32[] arrayAudio; // Array to import the Audio Position order in to
    public Int32[] arrayArrow; // Array to impoert the Arrow Position Order in to
    public int arraySize; // Defines size of arrayAudio and arrayArrow according to the imported numberSignals
    private bool beeingHandled; // Bool for the subroutine
    public int numberSpeakers; // Number of speakers available
    public GameObject scriptObject; UnityServer getAudioPositions, getArrowPositions, getNumberSignals; // Variables for imported Variables

    void Awake()
    {
        getAudioPositions = scriptObject.GetComponent<UnityServer>();
        getArrowPositions = scriptObject.GetComponent<UnityServer>();
        getNumberSignals = scriptObject.GetComponent<UnityServer>();        
    }

    void Start()
    {   
        // Load the five audiosources into the audioSource array
        audioSource = GetComponentsInChildren<AudioSource>();
        // Initialize the angles array for arrow positioning
        angles = new float[5];
        angles[0] = 90.0f;
        angles[1] = 45.0f;
        angles[2] = 0.0f;
        angles[3] = -45.0f;
        angles[4] = -90.0f;

        rotX = angles[2];
        beeingHandled = false;      
    }
    
    void Update()
    {       
        arraySize = getNumberSignals.numberSignals;
        arrayArrow = new Int32[arraySize];
        arrayAudio = new Int32[arraySize];
               
        for (int i = 0; i < arraySize; i++)
        {
            arrayAudio[i] = getAudioPositions.audioPositions[i];
            arrayArrow[i] = getArrowPositions.arrowPositions[i];
        }

        if (Input.GetKey(KeyCode.Space) && beeingHandled == false)
        {
            StartCoroutine(HandleIt());   
        }        
    }

    private IEnumerator HandleIt()
    {
        beeingHandled = true;

        for (int i = 0; i < arraySize; i++)
        {
            if (arrayAudio[i] == 0)
            {
                if(arrayArrow[i] == arrayAudio[i])
                {
                    rotX = angles[0];
                    print("Audio from L90 , Arrow to L90");
                }
                else
                {
                    int x = arrayArrow[i];
                    rotX = angles[x];
                    print("Audio from L90");
                }                                 
                audioSource[0].PlayOneShot(sound);                
            }
            if (arrayAudio[i] == 1)
            {
                if (arrayArrow[i] == arrayAudio[i])
                {
                    rotX = angles[1];
                    print("Audio from L30 , Arrow to L30");
                }
                else
                {
                    int x = arrayArrow[i];
                    rotX = angles[x];
                    print("Audio from L30");
                }
                audioSource[1].PlayOneShot(sound);                
            }
            if (arrayAudio[i] == 2)
            {
                if (arrayArrow[i] == arrayAudio[i])
                {
                    rotX = angles[3];
                    print("Audio from R30 , Arrow to R30");
                }
                else
                {
                    int x = arrayArrow[i];
                    rotX = angles[x];
                    print("Audio from R30");
                }
                audioSource[2].PlayOneShot(sound);                
            }
            if (arrayAudio[i] == 3)
            {
                if (arrayArrow[i] == arrayAudio[i])
                {
                    rotX = angles[4];
                    print("Audio from R90 , Arrow to R90");
                }
                else
                {                 
                    int x = arrayArrow[i];
                    rotX = angles[x];
                    print("Audio from R90");
                }
                audioSource[3].PlayOneShot(sound);                
            }
             yield return new WaitForSeconds(5.0f);
        }        
        beeingHandled = false;
        print("Routine finished!");
    }
}