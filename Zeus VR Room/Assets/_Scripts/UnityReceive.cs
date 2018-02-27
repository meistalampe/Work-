using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using System.Net.NetworkInformation;
using UnityEngine;
using System.Net;
using System;

public class UnityReceive : MonoBehaviour {

    // Use this for initialization
    TcpListener listener;
    String msg;

    byte[] data = new Byte[256];
    public double depth;

	void Start ()
    {   
        // Initializing depth parameter, to a value of 5
        depth = 5.0;
        // Initializing and starting the listener for the connection
        listener = new TcpListener(8632);
        listener.Start();
        print("Unity is listening");
	}
	
	// Update is called once per frame
	void Update ()
    {
		if (!listener.Pending())
        {
            
        }
        else
        {
            print("socket comes");

            TcpClient client = listener.AcceptTcpClient();
            NetworkStream stream = client.GetStream();
            StreamReader reader = new StreamReader(stream);

            // Reading the transmited data and saving as a string
            msg = reader.ReadToEnd();
            print(msg);

            // Store the received Data in data array
            data = System.Text.Encoding.ASCII.GetBytes(msg);

            //// extract Y coordinate of floorposition
            //depth = Convert.ToDouble(data[0]);
        }
	}
}
