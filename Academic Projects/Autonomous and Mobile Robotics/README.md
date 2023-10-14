# Autonomous Navigation of a sanitizer robot in ROS2 using Reinforcement Learning 

A sanitizer robot is required to map and navigate the environment, in order to be able to reach and sanify different rooms in a house. SLAM is used for th mapping of the environment, which is scanned by a greedy frontier-based exploration algorithm. Localization perfomed using the AMCL algorithm. A Reinforcement Learning approach is adopted to try to establish the most efficient path to follow to sanify the rooms. A DQN model with an MLP policy network is used. Dynimical avoidance of obstacles is demanded.
