// filename: UnityServer.cs
// Saarland University of Applied Sciences
// author: Dominik Limbach
// date: 01.11.2017

// description: the program will read data from the stream and store
// crucial information into variables


using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using System.Net.NetworkInformation;
using UnityEngine;
using System.Net;
using System;

public class UnityServer : MonoBehaviour
{
    // Use this for initialization
    TcpListener listener;
    String msg;
    // determines data size
    byte[] data = new Byte[256];
    // intialize exam parameter variables
    public int numberSignals;
    public Int32[] audioPositions;
    public Int32[] arrowPositions;

    private void Awake()
    {   
        numberSignals = 5;                          
        audioPositions = new Int32[numberSignals];
        arrowPositions = new Int32[numberSignals];
    }

    void Start()
    {
        listener = new TcpListener(8633);
        listener.Start();
        print("Server is listening.");

    }

    // Update is called once per frame
    void Update()
    {
        if (!listener.Pending())
        {
        }
        else
        {
            print("Data received.");
            TcpClient client = listener.AcceptTcpClient();
            NetworkStream stream = client.GetStream();
            StreamReader reader = new StreamReader(stream);
            msg = reader.ReadToEnd();

            // Store the received Data in data array
            data = System.Text.Encoding.ASCII.GetBytes(msg);

            // extract the number of signals per set
            numberSignals = Convert.ToInt32(data[0]);

            audioPositions = new Int32[numberSignals];
            arrowPositions = new Int32[numberSignals];

            // extract data from stream
            for (int i = 0; i < numberSignals; i++)
            {
                // extract the audio positions
                audioPositions[i] = Convert.ToInt32(data[i + 1]);
                // extract the arrow positions
                arrowPositions[i] = Convert.ToInt32(data[i + 1 + numberSignals]);
            }    

        }
    }
}