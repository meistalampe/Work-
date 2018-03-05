using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class spawn_sphere_object : MonoBehaviour {

    //public GameObject sphere_clone;
    //public GameObject Respawn_Guard;
    bool is_created = false;
    float time_passed = 0.0f;

    //sphere_clone = (GameObject)Resources.Load("prefabs/sphere", typeof(GameObject));

    // Use this for initialization
    void Start () {
        
	}
	
	// Update is called once per frame
	void Update () {

        time_passed += Time.deltaTime;

        if (Input.GetKeyDown(KeyCode.F1) && time_passed >= 0.5){

            //Respawn_Guard = GameObject.Find("Sphere");
            //Debug.Log("Found the sphere" + Respawn_Guard.ToString());

            //Instantiate(sphere_clone, new Vector3(2.0f, 0.2f, 1.1f), Quaternion.identity);

            

        
             GameObject instance = Resources.Load("prefabs/new_prefab", typeof(GameObject)) as GameObject;

             Debug.Log("Key pressed" + instance.ToString());

             Instantiate(instance, new Vector3(2f, 0.2f, 0.9f), Quaternion.identity);

             time_passed = 0f;
             
        }
        
	}
}
