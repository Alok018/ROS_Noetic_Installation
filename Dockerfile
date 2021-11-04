ARG BASE_IMAGE=ubuntu:focal
FROM ${BASE_IMAGE}

ARG ROS_PKG=ros-noetic-desktop-full
ENV ROS_DISTRO=noetic
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

# add the ROS deb repo to the apt sources list
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
		cmake \
		build-essential \
		curl \
		wget \
		gnupg2 \
		lsb-release \
    && rm -rf /var/lib/apt/lists/*
    
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install bootstrap dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
          python3-rosdep \
          python3-rosinstall-generator \
          python3-vcstool \
          build-essential && \
    rosdep init && \
    rosdep update && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir ros_catkin_ws && \
    cd ros_catkin_ws && \
    rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall && \
    mkdir ./src && \
    vcs import --input noetic-desktop.rosinstall ./src && \
    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y && \
    
RUN source ~/ros_catkin_ws/install_isolated/setup.bash
WORKDIR /
