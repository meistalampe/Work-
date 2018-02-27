using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayAudio : MonoBehaviour {
    AudioSource playAudio;
    // Use this for initialization
    void Start ()
    {
        playAudio = GetComponent<AudioSource>();
       
    }
	
	// Update is called once per frame
	void Update ()
    {
		if(Input.GetKeyDown(KeyCode.Space))
        {
            playAudio.Play();
            playAudio.Play(44100);
        }
	}
}
