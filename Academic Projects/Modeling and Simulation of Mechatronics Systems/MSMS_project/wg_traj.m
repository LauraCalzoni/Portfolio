function [qw_des] = wg_traj(qi_des,ddqi_des,g,N,K,Ji)
%WG_TRAJ Function computing the wave generator trajectory, given the desired joint
%motion provided by the inverse kinematics
   
    qw_des = N*qi_des + (N*Ji/K)*ddqi_des - (N/K)*g;
     
end

