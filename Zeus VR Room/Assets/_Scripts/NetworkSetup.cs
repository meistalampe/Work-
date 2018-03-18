
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using System.Text;

public class NetworkSetup : MonoBehaviour
{
    TcpClient client;
    const int READ_BUFFER_SIZE = 255;

    TcpListener listener;
    NetworkStream stream;
    StreamReader reader;

    byte[] data = new Byte[READ_BUFFER_SIZE];
    string strBytesRead;
    string strMessage;

    public struct User
    {
        public float depth, upperBorder, lowerBorder, speed;
        public int reaction;

        public User(float d, int r, float uB, float lB, float s)
        {
            depth = d;
            reaction = r;
            upperBorder = uB;
            lowerBorder = lB;
            speed = s;
        }
    }

    public User physician, ai, input;

    public bool physicianActivity;
    public float depthDefault;
    public int range;
    public float ubDefault;
    public float lbDefault;
    public float speedDefault;
    public bool lightEvent;
    public int lightColor;
    public bool openFloorSequence;
    public int targetPositionFloor;
    // floor positions
    // 0 = closed
    // 1 = 1/3 open
    // 2 = 2/3 open
    // 3 = fully open
    public int bridgeWidth;
    // width
    // 0 = 0.25f
    // 1 = 0.5f
    // 2 = 0.75f
    // 3 = 1.0f

    // reaction values:
    // 4 = abort , init value
    // 3 = move to
    // 2 = higher
    // 1 = deeper
    // 0 = no change

    // range values
    // 0 = default, no physician activity ,full range
    // 1 = range has to be set by physician
    // depth values from 1.0f - 30.0f

    void Start()
    {
        // initialize parameter

        physicianActivity = false;
        range = 0;
        depthDefault = 1.0f;
        ubDefault = 1.0f;
        lbDefault = 40.0f;
        speedDefault = 0.5f;

        lightEvent = false;
        lightColor = 0;

        openFloorSequence = false;
        targetPositionFloor = 0;
        bridgeWidth = 1;

        ai = new User(depthDefault, 4, ubDefault, lbDefault, speedDefault);
        physician = ai;
        input = ai;


        listener = new TcpListener(8632);
        listener.Start();
        print("Unity is listening.");
    }

    void Update()
    {
        if (!listener.Pending())
        {

        }
        else
        {
            print("Data Received.");
            client = listener.AcceptTcpClient();

            if (client != null)
            {
                Debug.Log("Connected!");
            }

            stream = client.GetStream();
            reader = new StreamReader(stream);

            // receive data as string msg

            strMessage = reader.ReadToEnd();

            // encode and store the reveived data in data array
            data = System.Text.Encoding.ASCII.GetBytes(strMessage);
            
            strBytesRead = System.Text.Encoding.ASCII.GetString(data);
            Debug.Log("Received:" + strBytesRead + "data");
            //strBytesRead = Convert.ToBase64String(data);
            //Debug.Log(strBytesRead);

            // data has to be sent in the following order
            // data[0] = bool physicianActivity
            // data[1] = int range
            // data[2] = float depth
            // data[3] = int reation
            // data[4] = float uB
            // data[5] = float lB
            // data[6] = float speed
            // data[7] = bool lightEvent
            // data[8] = int lightColor
            // data[9] = bool openFloorSequence
            // data[10] = int targetPositionFloor
            // data[11] = int bridgeWidth

            physicianActivity = Convert.ToBoolean(data[0]);
            range = Convert.ToInt32(data[1]);
            lightEvent = Convert.ToBoolean(data[7]);
            lightColor = Convert.ToInt32(data[8]);
            openFloorSequence = Convert.ToBoolean(data[9]);
            targetPositionFloor = Convert.ToInt32(data[10]);
            bridgeWidth = Convert.ToInt32(data[11]);

            if (physicianActivity == true)
            {
                physician.depth = Convert.ToSingle(data[2]);
                physician.reaction = Convert.ToInt32(data[3]);
                physician.upperBorder = Convert.ToSingle(data[4]);
                physician.lowerBorder = Convert.ToSingle(data[5]);

                if (Convert.ToSingle(data[6]) <= 3.0 && Convert.ToSingle(data[6]) > 0.0)
                {
                    physician.speed = Convert.ToSingle(data[6]);
                }
                else
                {
                    physician.speed = speedDefault;
                }

                input = physician;
            }
            else
            {
                ai.depth = Convert.ToSingle(data[2]);
                ai.reaction = Convert.ToInt32(data[3]);
                ai.upperBorder = ubDefault;
                ai.lowerBorder = lbDefault;
                ai.speed = speedDefault;

                input = ai;
            }




        }
    }
}