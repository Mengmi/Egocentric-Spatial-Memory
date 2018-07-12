#include <ros/ros.h>
#include "gazebo_msgs/ModelState.h"
#include<tf/transform_broadcaster.h>
#include <sensor_msgs/JointState.h>
#include <std_msgs/Float64.h>
#include "std_msgs/Float32MultiArray.h"

#include <signal.h>
#include <termios.h>
#include <stdio.h>
#include <vector>
#include <stdlib.h>
#include <iostream>
#include <fstream>
 
//for keyboard definition
#define PI 3.14159265
#define KEYCODE_Xmas 0x43
#define KEYCODE_Xmenos 0x44
#define KEYCODE_Ymas 0x41
#define KEYCODE_Ymenos 0x42
#define KEYCODE_Zmas 0x77
#define KEYCODE_Zmenos 0x73
#define KEYCODE_XgiroMas 0x61
#define KEYCODE_XgiroMenos 0x64
#define KEYCODE_YgiroMas 0x65
#define KEYCODE_YgiroMenos 0x71

//for direction press classification
#define FORWARD 1
#define BACKWARD 2
#define LEFTWARD 3
#define RIGHTWARD 4
#define ROTATELEFT 5
#define ROTATERIGHT 6
 
/////////////////global var/////////////////////
struct termios cooked, raw; //for keyboard
int cont = 0;
double retardo = 0.1;

//save keyboard motion to file
std::ofstream RecordKeyboard;
int indexR = 1;

//gazebo state
gazebo_msgs::ModelState objeto;
std_msgs::Float32MultiArray GlobalPose;

double R_alti =0;
double R_yaw = 0;
double R_x = 0;
double R_y = 0;
double S_yaw = 0.1;
double S_x = 0.1; //offset movement
double S_y = 0.1; //offset movement

std::string writeFilePath = "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/worldDescription/record/rec_world2temp.txt";

void quit(int sig)
{
  tcsetattr(0, TCSANOW, &cooked);
  ros::shutdown();
  exit(0);
}

void callback(const ros::TimerEvent&)
{
 
        ros::NodeHandle n;
       
        ros::Publisher object_pub_=n.advertise<gazebo_msgs::ModelState>("gazebo/set_model_state", 1);
        std::string modelo_objeto;

        ros::Publisher pub_GlobalPose;
        pub_GlobalPose = n.advertise<std_msgs::Float32MultiArray>("GlobalPose", 1);

        ros::NodeHandle nh("~");
        nh.param("modelo_objeto", modelo_objeto, std::string("Lata_amstel"));

        ros::Time anterior;

        if (::cont == 0)
        {
                anterior = ros::Time::now();
               
                geometry_msgs::Quaternion q= tf::createQuaternionMsgFromYaw(R_yaw);

                ::objeto.model_name = "myRobot";
                ::objeto.reference_frame = "world";
                ::objeto.pose.position.x = R_x;
                ::objeto.pose.position.y = R_y;
                ::objeto.pose.position.z = R_alti;
                ::objeto.pose.orientation.x = q.x;
                ::objeto.pose.orientation.y = q.y;
                ::objeto.pose.orientation.z = q.z;
                ::objeto.pose.orientation.w = q.w;
                ::cont = 1;
                object_pub_.publish(::objeto);

                GlobalPose.data[0]= ((float)R_x);
                GlobalPose.data[1]= ((float)R_y);
                GlobalPose.data[2]= ((float)R_alti);
                GlobalPose.data[3]= ((float)R_yaw);
                pub_GlobalPose.publish(GlobalPose);
               
        }
       
  char c;

  // get the console in raw mode                                                              
  tcgetattr(0, &cooked);
  memcpy(&raw, &cooked, sizeof(struct termios));
  raw.c_lflag &=~ (ICANON | ECHO);
  // Setting a new line, then end of file                        
  raw.c_cc[VEOL] = 1;
  raw.c_cc[VEOF] = 2;
  tcsetattr(0, TCSANOW, &raw);

  puts("");
  puts("#####################################################");
  puts("                   CONTROLES myRobot");
  puts("#####################################################");
  puts("");  
  puts("Up arrow:_______________________ Move forward object");
  puts("Down arrow:_____________________ Move backward object");
  puts("Left arrow:_____________________ Move left object");
  puts("Right arrow:____________________ Move right object");
  //puts("W key:__________________________ Move forward object");
  //puts("S key:__________________________ Move backward object");
  puts("A key:__________________________ Yaw + z axis object");
  puts("D key:__________________________ Yaw - z axis object");
  //puts("Q key:__________________________ Tilt + z axis object");
  //puts("E key:__________________________ Tilt - z axis object");

       
    while (ros::ok())
    {
               
                       
		// get the next event from the keyboard
		if(read(0, &c, 1) < 0)
		{
		  perror("read():");
		  exit(-1);
		}

		  //move x
		  if (c == KEYCODE_Xmas)
		  {
					if (ros::Time::now() > anterior + ros::Duration(::retardo))
					{
							R_x = R_x + S_x * cos(R_yaw + PI/2);
							R_y = R_y + S_x * sin(R_yaw + PI/2);
							//world_tf.transform.translation.x = R_x;
							::objeto.pose.position.x = R_x;
							::objeto.pose.position.y = R_y;
							anterior = ros::Time::now();
							//save keyboard motion
							RecordKeyboard<<indexR <<" ";
							RecordKeyboard<<(float) R_x <<" ";
							RecordKeyboard<<(float) R_y <<" ";
							RecordKeyboard<<(float) R_yaw <<" ";
							RecordKeyboard<<(float) RIGHTWARD <<" ";
							RecordKeyboard<<std::endl;
							indexR =indexR + 1;
					}
		  }
		  if (c == KEYCODE_Xmenos)
		  {
					if (ros::Time::now() > anterior + ros::Duration(::retardo))
					{
						    R_x = R_x + S_x * cos(R_yaw + 3*PI/2);
							R_y = R_y + S_x * sin(R_yaw + 3*PI/2);
							//world_tf.transform.translation.x = R_x;
							::objeto.pose.position.x = R_x;
							::objeto.pose.position.y = R_y;
							anterior = ros::Time::now();
							//save keyboard motion
							RecordKeyboard<<indexR <<" ";
							RecordKeyboard<<(float) R_x <<" ";
							RecordKeyboard<<(float) R_y <<" ";
							RecordKeyboard<<(float) R_yaw <<" ";
							RecordKeyboard<<(float) LEFTWARD <<" ";
							RecordKeyboard<<std::endl;
							indexR =indexR + 1;
					}
		  }

		  //move y
		  if (c == KEYCODE_Ymas)
		  {
					if (ros::Time::now() > anterior + ros::Duration(::retardo))
					{
						    R_x = R_x + S_y * cos(R_yaw + PI);
							R_y = R_y + S_y * sin(R_yaw + PI);
							//world_tf.transform.translation.y = R_y;
							::objeto.pose.position.x = R_x;
							::objeto.pose.position.y = R_y;
							anterior = ros::Time::now();
							//save keyboard motion
							RecordKeyboard<<indexR <<" ";
							RecordKeyboard<<(float) R_x <<" ";
							RecordKeyboard<<(float) R_y <<" ";
							RecordKeyboard<<(float) R_yaw <<" ";
							RecordKeyboard<<(float) FORWARD <<" ";
							RecordKeyboard<<std::endl;
							indexR =indexR + 1;
					}
		  }
		  if (c == KEYCODE_Ymenos)
		  {
					if (ros::Time::now() > anterior + ros::Duration(::retardo))
					{
							R_x = R_x + S_y * cos(R_yaw );
							R_y = R_y + S_y * sin(R_yaw );
							//world_tf.transform.translation.y = R_y;
							::objeto.pose.position.x = R_x;
							::objeto.pose.position.y = R_y;
							anterior = ros::Time::now();
							//save keyboard motion
							RecordKeyboard<<indexR <<" ";
							RecordKeyboard<<(float) R_x <<" ";
							RecordKeyboard<<(float) R_y <<" ";
							RecordKeyboard<<(float) R_yaw <<" ";
							RecordKeyboard<<(float) BACKWARD <<" ";
							RecordKeyboard<<std::endl;
							indexR =indexR + 1;
					}
		  }

		  //move yaw
		  if (c == KEYCODE_XgiroMas)
		  {
					if (ros::Time::now() > anterior + ros::Duration(::retardo))
					{
							R_yaw = R_yaw + S_yaw;
							geometry_msgs::Quaternion q= tf::createQuaternionMsgFromYaw(R_yaw);
							::objeto.pose.orientation.x = q.x;
							::objeto.pose.orientation.y = q.y;
							::objeto.pose.orientation.z = q.z;
							::objeto.pose.orientation.w = q.w;
							//world_tf.transform.rotation = q;
							anterior = ros::Time::now();

							//save keyboard motion
							RecordKeyboard<<indexR <<" ";
							RecordKeyboard<<(float) R_x <<" ";
							RecordKeyboard<<(float) R_y <<" ";
							RecordKeyboard<<(float) R_yaw <<" ";
							RecordKeyboard<<(float) ROTATELEFT <<" ";
							RecordKeyboard<<std::endl;
							indexR =indexR + 1;
					}
		  }
		  if (c == KEYCODE_XgiroMenos)
		  {
					if (ros::Time::now() > anterior + ros::Duration(::retardo))
					{
							R_yaw = R_yaw - S_yaw;
							geometry_msgs::Quaternion q= tf::createQuaternionMsgFromYaw(R_yaw);
							::objeto.pose.orientation.x = q.x;
							::objeto.pose.orientation.y = q.y;
							::objeto.pose.orientation.z = q.z;
							::objeto.pose.orientation.w = q.w;
							//world_tf.transform.rotation = q;
							anterior = ros::Time::now();

							//save keyboard motion
							RecordKeyboard<<indexR <<" ";
						    RecordKeyboard<<(float) R_x <<" ";
						    RecordKeyboard<<(float) R_y <<" ";
						    RecordKeyboard<<(float) R_yaw <<" ";
						    RecordKeyboard<<(float) ROTATERIGHT <<" ";
						    RecordKeyboard<<std::endl;
						    indexR =indexR + 1;

					}
		  }

		  //world_tf.header.frame_id = "world";
		  //world_tf.child_frame_id = "body";
		  ::objeto.model_name = "myRobot";
		  ::objeto.reference_frame = "world";
		  ::objeto.pose.position.z = R_alti;
		  //::objeto.twist = start_twist;
		  object_pub_.publish(::objeto);

		  GlobalPose.data[0]= ((float)R_x);
		  GlobalPose.data[1]= ((float)R_y);
		  GlobalPose.data[2]= ((float)R_alti);
		  GlobalPose.data[3]= ((float)R_yaw);
		  pub_GlobalPose.publish(GlobalPose);
		  //tf_broadcaster_world.sendTransform(world_tf);

		  ros::spinOnce();



      }// end of while loop


}
 
  int main(int argc, char **argv)
  {
 
        ros::init(argc, argv, "keyboardcontrol");
 
        ros::NodeHandle n;
       
        ros::Publisher object_pub_=n.advertise<gazebo_msgs::ModelState>("gazebo/set_model_state", 1);
        ros::Publisher pub_GlobalPose;
        pub_GlobalPose = n.advertise<std_msgs::Float32MultiArray>("GlobalPose", 1);
        for(int i=0;i<4;i++)
        {
        	GlobalPose.data.push_back(0);
        }

        //save keyboard motion to file
        RecordKeyboard.open(writeFilePath.c_str());


        signal(SIGINT,quit);
       
        ros::Timer timer = n.createTimer(ros::Duration(1), callback);
 
        ros::spin();

        RecordKeyboard.close();
 
        return 0;
  }
