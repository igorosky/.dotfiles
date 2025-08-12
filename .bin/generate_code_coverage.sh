#!/bin/bash

set -e

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "lcov could not be found. Please install it first. (sudo apt-get install lcov)"
    exit 1
fi

PACKAGES_SELECT=''


if [ "$#" -ge 1 ]; then
    PACKAGES_SELECT="--packages-select $@"
fi

colcon build --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage" -DCMAKE_C_FLAGS="--coverage" $PACKAGES_SELECT
lcov --no-external --capture --initial --directory . --output-file ros2_base.info
colcon test $PACKAGES_SELECT
lcov --no-external --capture --directory . --output-file ros2.info
lcov --add-tracefile ros2_base.info --add-tracefile ros2.info --output-file ros2_coverage.info
mkdir -p coverage
genhtml ros2_coverage.info --output-directory coverage
echo "Open coverage: file://$(realpath coverage/index.html)"
