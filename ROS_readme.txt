#This readme.txt describes how to generate training data and test data for Egocentric Spatial Memory
#We used ROS jade version

#Create a ROS workspace using:
source /opt/ros/jade/setup.bash
mkdir ROSsimulation
mkdir ROSsimulation/src
cd ROSsimulation
catkin_make
source devel/setup.bash

#You might want to add in ~/.bashrc using
gedit ~/.bashrc

#add the following (change the directory to your workspace path)
export PYTHONPATH="/usr/lib/python2.7/dist-packages:$PYTHONPATH"
source /opt/ros/jade/setup.bash
. ~/Desktop/Egocentric-Spatial-Memory/ROSsimulation/devel/setup.bash

#And copy two packages below to the ROSsimulation workspace:
worldDescription
local_map

#compile and make:
catkin_make
#load to Eclipse if you want to (optional)
catkin_make --force-cmake -G"Eclipse CDT4 - Unix Makefiles"


#to launch maze/berkley2D3DS dataset
#In "ROSsimulation/src/worldDescription/launch/worldlaunchIROS.launch"
#change <arg name="world_name" value="$(find worldDescription)/world/world2wd.world"/>
#for berkley2D3DS dataset
#change <arg name="world_name" value="$(find worldDescription)/world/berkley1/berkley_world.world"/>
# to load different worlds 
roslaunch worldDescription worldlaunchIROS.launch

#to launch local map generation
roslaunch worldDescription localMap.launch

#to use keyboard to move robot around in the simulated envieronemnt to generate pre-defined trajectory
#the generated trajectory is recorded in worldDescription/record folder
#open worldDescription/src/KeyboardControl.cpp to change the directory of saved trajectory (std::string writeFilePath)
#if you want to use our pre-defined trajectory; skip this step
#all the pre-defined trajectories are stored in worldDescription/record folder
rosrun worldDescription KeyboardControl

#it will load the pre-defined trajectory text file and move the robot, collect camera frames and the ground truth local maps
#the stored camera frames and local maps are in "Egocentric-Spatial-Memory/Data/world2/" folder
#open worldDescritpion/src/MoveRobot.cpp to change the path of saved camera frames and local maps 
#(std::string prefixMapPath, std::string prefixCameraPath)
#change the path of pre-defined trajectory:
#(std::string filename)
rosrun worldDescription MoveRobot


