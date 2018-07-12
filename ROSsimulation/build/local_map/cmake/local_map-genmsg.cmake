# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "local_map: 0 messages, 1 services")

set(MSG_I_FLAGS "")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(local_map_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv" NAME_WE)
add_custom_target(_local_map_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "local_map" "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv" ""
)

#
#  langs = gencpp;geneus;genlisp;genpy
#

### Section generating for lang: gencpp
### Generating Messages

### Generating Services
_generate_srv_cpp(local_map
  "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/local_map
)

### Generating Module File
_generate_module_cpp(local_map
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/local_map
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(local_map_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(local_map_generate_messages local_map_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv" NAME_WE)
add_dependencies(local_map_generate_messages_cpp _local_map_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(local_map_gencpp)
add_dependencies(local_map_gencpp local_map_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS local_map_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages

### Generating Services
_generate_srv_eus(local_map
  "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/local_map
)

### Generating Module File
_generate_module_eus(local_map
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/local_map
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(local_map_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(local_map_generate_messages local_map_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv" NAME_WE)
add_dependencies(local_map_generate_messages_eus _local_map_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(local_map_geneus)
add_dependencies(local_map_geneus local_map_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS local_map_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages

### Generating Services
_generate_srv_lisp(local_map
  "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/local_map
)

### Generating Module File
_generate_module_lisp(local_map
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/local_map
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(local_map_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(local_map_generate_messages local_map_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv" NAME_WE)
add_dependencies(local_map_generate_messages_lisp _local_map_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(local_map_genlisp)
add_dependencies(local_map_genlisp local_map_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS local_map_generate_messages_lisp)

### Section generating for lang: genpy
### Generating Messages

### Generating Services
_generate_srv_py(local_map
  "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/local_map
)

### Generating Module File
_generate_module_py(local_map
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/local_map
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(local_map_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(local_map_generate_messages local_map_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/mengmi/Desktop/Egocentric-Spatial-Memory/ROSsimulation/src/local_map/srv/SaveMap.srv" NAME_WE)
add_dependencies(local_map_generate_messages_py _local_map_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(local_map_genpy)
add_dependencies(local_map_genpy local_map_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS local_map_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/local_map)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/local_map
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/local_map)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/local_map
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/local_map)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/local_map
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/local_map)
  install(CODE "execute_process(COMMAND \"/home/mengmi/anaconda2/bin/python\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/local_map\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/local_map
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
