cmake_minimum_required(VERSION 2.8.3)
project(worldDescription)

## Add support for C++11, supported in ROS Kinetic and newer
# add_definitions(-std=c++11)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  roscpp
  rospy
  std_msgs

  tf
  nav_msgs
  sensor_msgs
  laser_geometry
  cv_bridge
  image_transport
)

catkin_package(
INCLUDE_DIRS include
)


include_directories(
  ${catkin_INCLUDE_DIRS}
  ##"/home/mengmi/Proj/Proj_3D/referenceROS/ROSWorkspace/src/myUAV_description/include/myUAV_description"  
)

add_executable(TFpub src/TFpub.cpp)
add_executable(MoveRobot src/MoveRobot.cpp)
add_executable(KeyboardControl src/KeyboardControl.cpp)

target_link_libraries(TFpub ${catkin_LIBRARIES} )
target_link_libraries(MoveRobot ${catkin_LIBRARIES} )
target_link_libraries(KeyboardControl ${catkin_LIBRARIES} )

