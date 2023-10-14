#!/usr/bin/env python3

import numpy as np
import random

import time
import rclpy
from rclpy.node import Node
from rclpy.qos import QoSDurabilityPolicy, QoSHistoryPolicy, QoSReliabilityPolicy, qos_profile_sensor_data
from rclpy.qos import QoSProfile

from geometry_msgs.msg import Twist, PoseWithCovarianceStamped
from sensor_msgs.msg import LaserScan


class RobotMover(Node):
    
    LINEAR_SPEED = 0.4
    ANGULAR_SPEED = -0.3

    def __init__(self):
        super().__init__('robot_mover')

        amcl_pose_qos = QoSProfile(
          durability=QoSDurabilityPolicy.TRANSIENT_LOCAL,
          reliability=QoSReliabilityPolicy.RELIABLE,
          history=QoSHistoryPolicy.KEEP_LAST,
          depth=1)
              
        self.amcl_x = 0.0
        self.amcl_y = 0.0
        self.amcl_w = 0.0
        self.amcl_cov = np.zeros(36)
        self.dist_from_obst = np.zeros(360)
        self.flag_left = False
        self.flag_right = False
        self.end_localization = False

        self.publisher = self.create_publisher(Twist, 'cmd_vel', 10)
        self.pub = self.create_publisher(PoseWithCovarianceStamped, 'initialpose', 10)
        self.amcl_sub = self.create_subscription(PoseWithCovarianceStamped, 'amcl_pose', self.amcl_callback, amcl_pose_qos)
        self.laserScan_sub = self.create_subscription(LaserScan, 'scan', self.scanner_callback, qos_profile_sensor_data)
        timer_period = 0.1
        self.timer = self.create_timer(timer_period, self.timer_callback)
        self.counter = 0
        self.t0 = time.time()


    def scanner_callback(self, scan_msg):
        self.dist_from_obst = scan_msg.ranges
        # for i in range(360):
        #     self.get_logger().info(f"Distance from obstacles at grade {i} : {self.dist_from_obst[i]}")
        return

    def amcl_callback(self, amcl_msg):
        self.amcl_x = amcl_msg.pose.pose.position.x
        self.amcl_y = amcl_msg.pose.pose.position.y
        self.amcl_w = amcl_msg.pose.pose.orientation.w
        self.amcl_cov = amcl_msg.pose.covariance
        # self.get_logger().info(f"Robot position: ({self.amcl_x}, {self.amcl_y}, {self.amcl_w})")
        # self.get_logger().info(f"Covariance: {self.amcl_cov}")
        return


    def timer_callback(self):
        if self.counter == 0:
            init_pose = PoseWithCovarianceStamped()
            init_pose.header.frame_id = 'map'
            init_pose.pose.pose.position.x = 0.0
            init_pose.pose.pose.position.y = -2.0
            init_pose.pose.pose.orientation.w = 1.0
            # for i in range(36):
            #     init_pose.pose.covariance[i] =random.randint(1, 10)  #5

            self.pub.publish(init_pose)
        
        msg = Twist()

        msg.linear.x = RobotMover.LINEAR_SPEED
        msg.linear.y = 0.0
        msg.linear.z = 0.0
        msg.angular.x = 0.0
        msg.angular.y = 0.0
        msg.angular.z = 0.0

        right_range = self.dist_from_obst[340:]
        left_range = self.dist_from_obst[:20]

        if (any( el < 0.8 for el in left_range) and not self.flag_left) or (any( el < 0.8 for el in right_range) and self.flag_right):
            msg.linear.x = 0.0
            msg.angular.z = RobotMover.ANGULAR_SPEED
            self.flag_right = True
        
        if (any( el < 0.8 for el in right_range) and not self.flag_right) or (any( el < 0.8 for el in left_range) and self.flag_left):
            msg.linear.x = 0.0
            msg.angular.z = -RobotMover.ANGULAR_SPEED
            self.flag_left = True

        if msg.linear.x != 0.0:
            self.flag_left = False
            self.flag_right = False

        t1 = time.time()
        time_spent = t1-self.t0
        traveled_distance = time_spent*msg.linear.x
        # if traveled_distance != 0.0:
        #     print('traveled distance: ', traveled_distance)

        self.max_cov = 0.1
        if all(self.amcl_cov <= self.max_cov) and traveled_distance > 15:
            msg.linear.x = 0.0
            msg.angular.z = 0.0
            self.publisher.publish(msg)
            self.get_logger().info('the robot has stopped')
            self.get_logger().info(f"Robot position: ({self.amcl_x}, {self.amcl_y}, {self.amcl_w})\n\
                                   Covariance: {self.amcl_cov}")
            self.end_localization = True
        
        self.publisher.publish(msg)
        self.counter = self.counter+1
    
        return