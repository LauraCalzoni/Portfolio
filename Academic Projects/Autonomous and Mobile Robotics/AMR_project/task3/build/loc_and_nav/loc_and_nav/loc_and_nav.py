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

    robot_mover.get_logger().info('Performing robot localization...')
    while not robot_mover.end_localization:
        #print(robot_mover.end_localization)
        rclpy.spin_once(robot_mover)
    
    x_pose = robot_mover.amcl_x
    y_pose = robot_mover.amcl_y
    w_pose = robot_mover.amcl_w
    
    robot_mover.destroy_node() 

    ################## NAVIGATION #####################

    node = rclpy.create_node("navigate_to_pose_client")

    node.get_logger().info(f"STARTING NAVIGATION from the initial position:\n\
        x: {x_pose }\n\
        y: {y_pose }\n\
        w: {w_pose }\n ")

    # Create an action client to send the goal
    client = ActionClient(node, NavigateToPose, "/navigate_to_pose")

    # Wait for the action server to start up
    if not client.wait_for_server(timeout_sec=5.0):
        node.get_logger().error("Action server not available")
        rclpy.shutdown()
        return

    # Set the robot's goal pose from text file
    goal_pose = NavigateToPose.Goal()
    goal_pose.pose.header.frame_id = 'map'

    goal_coord = open("/home/luca/AMR_project/task3/src/loc_and_nav/loc_and_nav/goal3.txt","r")
    goal = np.zeros(4)

    for j in range(4):
        line = next(goal_coord)
        coord = line.split()
        goal[j] = coord[2]

    goal_coord.close()

    goal_pose.pose.pose.position.x = goal[0]
    goal_pose.pose.pose.position.y = goal[1]
    goal_pose.pose.pose.position.z = goal[2]
    goal_pose.pose.pose.orientation.w = goal[3]

    # Send the goal and wait for a result
    future = client.send_goal_async(goal_pose)
    rclpy.spin_until_future_complete(node, future)
    client_goal_handle = future.result()

    if client_goal_handle.accepted:
        node.get_logger().info('Goal accepted \n...Processing navigation...')
        result_future = client_goal_handle.get_result_async()
        rclpy.spin_until_future_complete(node, result_future)
        
        if result_future.result().status == GoalStatus.STATUS_SUCCEEDED:
            node.get_logger().info('Navigation succeded!')
        else:
            node.get_logger().info('Navigation failed.')

    else:
        node.get_logger().info('Goal rejected')

    rclpy.shutdown()


 
if __name__ == '__main__':
  main()

