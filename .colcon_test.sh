#!/bin/sh
INITIAL_DIR=$(pwd)
cd $HOME/ros2_ws
colcon build --cmake-clean-cache --cmake-args -DCMAKE_BUILD_TYPE=Release -Wno-error $@
colcon test $@
colcon test-result --verbose
cd $INITIAL_DIR
