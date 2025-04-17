#!/bin/sh
INITIAL_DIR=$(pwd)
cd $HOME/ros2_ws
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -Wno-error $@
cd $INITIAL_DIR
