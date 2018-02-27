using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using System.Net.NetworkInformation;
using UnityEngine;
using System.Net;
using System;

public class UnityServer : MonoBehaviour {

    // Use this for initialization

    //static void Connect(String server, String message)
    //{
    //    try
    //    {
    //        // Create a TcpClient.
    //        // Note, for this client to work you need to have a TcpServer 
    //        // connected to the same address as specified by the server, port
    //        // combination.
    //        Int32 port = 8632;
    //        TcpClient client = new TcpClient(server, port);

    //        // Translate the passed message into ASCII and store it as a Byte array.
    //        Byte[] data = System.Text.Encoding.ASCII.GetBytes(message);

    //        // Get a client stream for reading and writing.
    //        //  Stream stream = client.GetStream();

    //        NetworkStream stream = client.GetStream();

    //        // Send the message to the connected TcpServer. 
    //        stream.Write(data, 0, data.Length);

    //        Console.WriteLine("Sent: {0}", message);

    //        // Receive the TcpServer.response.

    //        // Buffer to store the response bytes.
    //        data = new Byte[256];

    //        // String to store the response ASCII representation.
    //        String responseData = String.Empty;

    //        // Read the first batch of the TcpServer response bytes.
    //        Int32 bytes = stream.Read(data, 0, data.Length);
    //        responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);
    //        Console.WriteLine("Received: {0}", responseData);

    //        // Close everything.
    //        stream.Close();
    //        client.Close();
    //    }
    //    catch (ArgumentNullException e)
    //    {
    //        Console.WriteLine("ArgumentNullException: {0}", e);
    //    }
    //    catch (SocketException e)
    //    {
    //        Console.WriteLine("SocketException: {0}", e);
    //    }

    //    Console.WriteLine("\n Press Enter to continue...");
    //    Console.Read();
    //}
    // Use this for initialization
    TcpListener listener;
    String msg;
    byte[] data = new Byte[256];
    public double depth;
    public int[] Positions;
    public int[] active; // bool didnt work somehow
    public bool useTransform;
    public Vector3 sourcePosition;

    
    void Start()
    {   
        // Initializing Depth Parameter
        depth = 5.0;

        listener = new TcpListener(8632);
        listener.Start();
        print("is listening");
    }
    // Update is called once per frame
    void Update()
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
            msg = reader.ReadToEnd();
            

            // Store the received Data in data array
            data = System.Text.Encoding.ASCII.GetBytes(msg);

            // extract Y coordinate of floorposition
            depth = Convert.ToDouble(data[0]);
            //System.Console.WriteLine("Tiefe: {0}", Convert.ToDouble(data[0]));


            // extract the Positions of Audiosource 
            //for (int i = 0; i < 8; i++)
            //{
            //    Positions[i] = Convert.ToInt32(data[i+1]);
                Positions[0] = Convert.ToInt32(data[1]);
                Positions[1] = Convert.ToInt32(data[2]);
                Positions[2] = Convert.ToInt32(data[3]);
                Positions[3] = Convert.ToInt32(data[4]);
                Positions[4] = Convert.ToInt32(data[5]);
                Positions[5] = Convert.ToInt32(data[6]);
                Positions[6] = Convert.ToInt32(data[7]);
                Positions[7] = Convert.ToInt32(data[8]);
            //}

            //System.Console.WriteLine("Audiosource Position: {0}", Convert.ToInt32(data[1]));

            // extract booleans to choose which AudioSource should be active
            //for (int i = 0; i < 8; i++)
            //{
            //    active[i] = Convert.ToInt32(data[i + 9]);
                active[0] = Convert.ToInt32(data[9]);
                active[1] = Convert.ToInt32(data[10]);
                active[2] = Convert.ToInt32(data[11]);
                active[3] = Convert.ToInt32(data[12]);
                active[4] = Convert.ToInt32(data[13]);
                active[5] = Convert.ToInt32(data[14]);
                active[6] = Convert.ToInt32(data[15]);
                active[7] = Convert.ToInt32(data[16]);
            //}

            //extraxt boolean to choose if movable Soundsource is used freely ( if useTransform = true)
            useTransform = Convert.ToBoolean(data[17]);

            // extract movable Soundsource Transform Position as a Vector 3
            sourcePosition = new Vector3(Convert.ToSingle(data[18]), Convert.ToSingle(data[19]), Convert.ToSingle(data[20]));

            // String to store the response ASCII representation.
            String responseData = String.Empty;

            //Read the first batch of the TcpServer response bytes.
            Int32 bytes = stream.Read(data, 0, data.Length);
            responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);
        //    System.Console.WriteLine("Received: {0}", responseData);
        }
    }
}

