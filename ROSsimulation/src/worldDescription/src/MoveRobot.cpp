/*
 * MoveUAV.cpp
 *
 *  Created on: 11 Oct, 2014
 *      Author: lin
 */

#include<ros/ros.h>
#include <gazebo_msgs/SetModelState.h>
#include<tf/transform_broadcaster.h>
#include "sensor_msgs/LaserScan.h"
#include "nav_msgs/OccupancyGrid.h"
#include <sensor_msgs/JointState.h>
#include <visualization_msgs/Marker.h>
#include <std_msgs/Float64.h>
#include "std_msgs/Float32MultiArray.h"
#include <visualization_msgs/Marker.h>

#include <stdio.h>
#include <vector>
#include <stdlib.h>
#include <iostream>
#include <fstream>

#include <opencv2/opencv.hpp>
#include <image_transport/image_transport.h>
#include <opencv2/highgui/highgui.hpp>
#include <cv_bridge/cv_bridge.h>
#include <opencv2/video/tracking.hpp>
#include <opencv2/video/video.hpp>
#include <opencv2/core/types_c.h>
#include <opencv2/core/core_c.h>

#define MOTION_UPDATE_RATE 50
#define CLASS_OCC 0
#define CLASS_FRE 255
#define CLASS_UNK 125

using namespace std;
using namespace cv;

int R_index = 0;
double R_alti =1.1;
double R_yaw = 0;
double R_x = 0;
double R_y = 0;
double R_control = 0;
double S_alti = 0.08;

//save keyboard motion to file
cv::Mat occumap; //local occupancy map
//std::stringstream mapstream("/home/mengmi/Proj/Proj_3D/ROSWork/src/worldDescription/MapData/map_world1.txt");
int layer = 1;

//save keyboard motion to file
void SaveimageCb(const sensor_msgs::ImageConstPtr& msg);
void HandleMap(const nav_msgs::OccupancyGrid::ConstPtr& ptr);

//std::string prefixMapPath = "/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World25/map/map_";
//std::string prefixCameraPath = "/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World25/camera_wd/camera_";

std::string prefixMapPath = "/home/mengmi/Desktop/Egocentric-Spatial-Memory/Data/world2/map/map_";
std::string prefixCameraPath = "/home/mengmi/Desktop/Egocentric-Spatial-Memory/Data/world2/camera_wd/camera_";


std::ifstream RecKeyboardFile;
//std::string filename = "/home/mengmi/Proj/Proj_3D/ROSWork/src/worldDescription/record/rec_world25.txt";
std::string filename = "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/worldDescription/record/rec_world2.txt";


int main(int argc, char** argv)
{
	
	//ROS stuff
	ros::init(argc, argv, "MoveRobot");
	ros::NodeHandle n;


	//Publisher
	ros::Publisher pub_GlobalPose;
	pub_GlobalPose = n.advertise<std_msgs::Float32MultiArray>("GlobalPose", 1);
	std_msgs::Float32MultiArray GlobalPose;
	for(int i=0;i<4;i++)
	{
		GlobalPose.data.push_back(0);
	}

	//service client for setting model state
	ros::Publisher object_pub_=n.advertise<gazebo_msgs::ModelState>("gazebo/set_model_state", 1);
	gazebo_msgs::ModelState objeto;
	geometry_msgs::Quaternion q= tf::createQuaternionMsgFromYaw(R_yaw);
	objeto.model_name = "myRobot";
	objeto.reference_frame = "world";
	objeto.pose.position.x = R_x;
	objeto.pose.position.y = R_y;
	objeto.pose.position.z = R_alti;
	objeto.pose.orientation.x = q.x;
	objeto.pose.orientation.y = q.y;
	objeto.pose.orientation.z = q.z;
	objeto.pose.orientation.w = q.w;

	//subscriber for camera image
	image_transport::Subscriber image_sub_;
	image_transport::ImageTransport it_(n);
	image_sub_ = it_.subscribe("/myRobot/camera0/image_raw0", 1,  &SaveimageCb);

	//subscriber for occupancy map
	ros::Subscriber scanHandler = n.subscribe<nav_msgs::OccupancyGrid>("/local_map/local_map", 1, HandleMap);

	//MapWriter.open(mapstream.str().c_str());
	//MapWriter << 10;

	//time control
	ros::Time anterior = ros::Time::now();
	double retardo = 0.1; //waiting duration

	ros::Rate rate(MOTION_UPDATE_RATE);
	//Heave Motion
	ROS_INFO("MOVE IT!");
	

	for (int i = 1; i<=1; i++)
	{
		RecKeyboardFile.open(filename.c_str());
		//ROS_INFO("Start Heaving One More Time!");
		//cout<<"Current Alti Index: "<< i <<endl;

		layer = i;
		R_alti = R_alti + S_alti;

		//Start moving
		while(ros::ok())
		{
			if (ros::Time::now() > anterior + ros::Duration(retardo))
			{

				anterior = ros::Time::now();
				std::string ReadInStr;
				if(std::getline(RecKeyboardFile, ReadInStr))
				{
					//preprocess and get global pose
					stringstream ss(ReadInStr);
					ss >> R_index;
					ss >> R_x;
					ss >> R_y;
					ss >> R_yaw;
                    ss >> R_control;
					cout<<"Iter: "<<R_index<<" "<<R_x<<" "<<R_y<<" "<<R_yaw<<" "<<R_control<<endl;

					//do sth about the read in poses
					//publish pose
					GlobalPose.data[0]= ((float)R_x);
					GlobalPose.data[1]= ((float)R_y);
					GlobalPose.data[2]= ((float)R_alti);
					GlobalPose.data[3]= ((float)R_yaw);


					//publish setmodelstate in gazebo
					geometry_msgs::Quaternion q= tf::createQuaternionMsgFromYaw(R_yaw);
					objeto.model_name = "myRobot";
					objeto.reference_frame = "world";
					objeto.pose.position.x = R_x;
					objeto.pose.position.y = R_y;
					objeto.pose.position.z = R_alti;
					objeto.pose.orientation.x = q.x;
					objeto.pose.orientation.y = q.y;
					objeto.pose.orientation.z = q.z;
					objeto.pose.orientation.w = q.w;

					//update occupancy map files path
					//MapWriter.close();
					//mapstream << "/home/mengmi/Proj/Proj_3D/ROSWork/src/worldDescription/MapData/map_"<< R_index<< "_"<< layer<< ".txt";
					//MapWriter.open(mapstream.str().c_str());

				}
				else
				{
					break;
				}//end of text file

			}//wait for enough long to stabilize robot and take measurements

			//publish state all the time
			//but only change state if enough time
			pub_GlobalPose.publish(GlobalPose);
			object_pub_.publish(objeto);

			//save occupancy map in callback
			//save camera image in callback

			ros::spinOnce();
			rate.sleep();


		}
		

		RecKeyboardFile.close();
		ROS_INFO("Process Completed at One Iteration!");
	}

	return 1; //end of main program
}


void SaveimageCb(const sensor_msgs::ImageConstPtr& msg)
{
	cv_bridge::CvImagePtr cv_ptr;
	try
	{
		cv_ptr = cv_bridge::toCvCopy(msg, sensor_msgs::image_encodings::BGR8);

	}
	catch (cv_bridge::Exception& e)
	{
		ROS_ERROR("cv_bridge exception: %s", e.what());
		return;
	}
	
	if (layer == 1)
	{
		//cout<<R_index<<endl;
		std::stringstream sstream;
		sstream << prefixCameraPath << R_index << ".jpg" ;
		cout<<sstream.str()<<endl;
		ROS_ASSERT( cv::imwrite( sstream.str(),  cv_ptr->image ) );
		//cout<<"camera image successfully written"<<endl;
	}


}

void HandleMap(const nav_msgs::OccupancyGrid::ConstPtr& ptr)
{
	occumap = Mat::zeros(ptr->info.width,ptr->info.height, CV_8UC1);
    int p = 0;
    int q = 0;

	for (size_t j = 0 ; j < (ptr->data.size()) -1 ; j++)
	{
		int valuetemp =  (ptr->data[j]);

		if (valuetemp > 50) //occupied
		{
			occumap.at<uchar>(p,q) = (uchar) CLASS_OCC ;
		}
		else if (valuetemp < 0) //unknown
		{
			occumap.at<uchar>(p,q) = (uchar) CLASS_UNK;
		}
		else //free
		{
			occumap.at<uchar>(p,q) = (uchar) CLASS_FRE;
		}

		if(p<ptr->info.width-1)
		{
			p++;
		}
		else
		{
			q++;
			p = 0;
		}
	}

	std::stringstream mapstream;
	mapstream << prefixMapPath<< R_index<< "_"<< layer<< ".jpg";
	ROS_ASSERT( cv::imwrite( mapstream.str(),  occumap ) );
	//cout<<"map successfully written"<<endl;


	return;
}

