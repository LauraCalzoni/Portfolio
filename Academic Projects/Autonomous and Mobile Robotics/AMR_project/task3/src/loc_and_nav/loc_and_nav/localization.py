#! /usr/bin/env python3

import rclpy
import numpy as np
from loc_and_nav.robot_mover import RobotMover
from rclpy.action import ActionClient
from nav2_msgs.action import NavigateToPose
from action_msgs.msg import GoalStatus


def main():
 
    # Start the ROS 2 Python Client Library
    rclpy.init()

    ################# LOCALIZATION ####################

    robot_mover = RobotMover()

    while not robot_mover.end_localization:
        #print(robot_mover.end_localization)
        rclpy.spin_once(robot_mover)
    
    robot_mover.destroy_node() 

    rclpy.shutdown()


 
if __name__ == '__main__':
  main()

