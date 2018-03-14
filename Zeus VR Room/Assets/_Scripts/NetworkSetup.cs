// variables needed
// physician avtivity
// reaction (higher ,lower)
// level change

// request fixed value for depth through physician
// request physician can set level borders 

//using System;
//using System.Collections;
//using System.Collections.Generic;
//using System.IO;
//using System.Net.Sockets;
//using UnityEngine;
//using UnityEngine.Networking;
//using UnityEngine.UI;

//public class NetworkSetup : MonoBehaviour
//{
//    TcpListener listener;
//    string msg;
//    byte[] data = new Byte[256];

//    public bool physicianActivity;
//    public float depthStart;
//    public float depthPhysician;
//    public int reaction;
//    public int reactionServer;
//    public int reactionPhysician;
//    // changeDepth values:
//    // 2 = higher
//    // 1 = deeper
//    // 0 = no change
//    public int range;
//    public float physicianUB;
//    public float physicianLB;
//    public float defaultUB;
//    public float defaultLB;
//    public float speed;
//    // range values
//    // 0 = default, no physician activity ,full range
//    // 1 = range has to be set by physician
//    // depth values from 1.0f - 30.0f

//    // if speed controlable then public float speed;

//    void Start()
//    {
//        // initialize parameter
//        depthStart = 1.0f;
//        physicianActivity = false;

//        reaction = 0;
//        reactionServer = 0;
//        reactionPhysician = 0;

//        defaultUB = 1.0f;
//        defaultLB = 30.0f;
//        physicianUB = defaultUB;
//        physicianLB = defaultLB;

//        listener = new TcpListener(8632);
//        listener.Start();
//        print("Unity is listening.");
//    }

//    void Update()
//    {
//        if (!listener.Pending())
//        {

//        }
//        else
//        {
//            print("Socket comes.");
//            TcpClient client = listener.AcceptTcpClient();
//            NetworkStream stream = client.GetStream();
//            StreamReader reader = new StreamReader(stream);

//            // receive data as string msg
//            msg = reader.ReadToEnd();
//            print(msg);

//            // encode and store the reveived data in data array
//            data = System.Text.Encoding.ASCII.GetBytes(msg);
//            // data has to be sent in the following order
//            // data[0] = bool physicianActivity
//            // data[1] = Int32 reactionServer 
//            // data[2] = Int32 reactionPhysician 
//            // data[3] = Int32 range
//            // data[4] = float physicianLB
//            // data[5] = float physicianUB
//            // data[6] = Int32 speed
//            physicianActivity = Convert.ToBoolean(data[0]);
//            reactionServer = Convert.ToInt32(data[1]);
//            reactionPhysician = Convert.ToInt32(data[2]);
//            range = Convert.ToInt32(data[3]);
//            physicianLB = Convert.ToSingle(data[4]);
//            physicianUB = Convert.ToSingle(data[5]);
//            depthPhysician = Convert.ToSingle(data[6]);
//            speed = Convert.ToSingle(data[7]);

//            if (Convert.ToSingle(data[7]) <= 1.0 && Convert.ToSingle(data[7]) > 0.0)
//            {
//                speed = Convert.ToSingle(data[7]);
//            }
//            else
//            {
//                speed = 0.5f;
//            }

//            if (physicianActivity == true)
//            {               
//                reaction = reactionPhysician;

//            }
//            else
//            {               
//                reaction = reactionServer;
//            }

//        }
//    }
//}

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

public class NetworkSetup : MonoBehaviour
{
    TcpListener listener;
    string msg;
    byte[] data = new Byte[256];

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
            print("Socket comes.");
            TcpClient client = listener.AcceptTcpClient();
            NetworkStream stream = client.GetStream();
            StreamReader reader = new StreamReader(stream);

            // receive data as string msg
            msg = reader.ReadToEnd();
            //print(msg);

            // encode and store the reveived data in data array
            data = System.Text.Encoding.ASCII.GetBytes(msg);
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