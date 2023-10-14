

%PARAMETERS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DH parameters

d1 = 0.089159 ;     %[m]
a1 = 0 ;            %[m]
alpha1 = 90 ;       %[°]

d2 = 0 ;            %[m]
a2 = -0.425 ;       %[m]
alpha2 = 0 ;        %[°]

d3 = 0 ;            %[m]
a3 = -0.39225 ;     %[m]
alpha3 = 0 ;        %[°]

d4 = 0.10915 ;      %[m]
a4 = 0 ;            %[m]
alpha4 = 90 ;       %[°]

d5 = 0.09465 ;      %[m]
a5 = 0 ;            %[m]
alpha5 = -90 ;      %[°]

d6 = 0.0823 ;       %[m]
a6 = 0 ;            %[m]
alpha6 = 0 ;        %[°]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inertia parameters

rG1= [0; -0.02561; 0.00193];    %[m]
rG2 = [0.2125; 0; 0.11336] ;    %[m]
rG3 = [0.15; 0; 0.0265];        %[m]
rG4 = [0; -0.0018; 0.01634];    %[m]
rG5 = [0; 0.0018; 0.01634];     %[m]
rG6 = [0; 0; -0.001159];        %[m]

m1 = 3.7;       %[kg]
m2 = 8.393;     %[kg]
m3 = 2.33;      %[kg]
m4 = 1.1219;    %[kg]
m5 = 1.1219;    %[kg]
m6 = 0.1879;    %[kg]

I1 = [0.0067; 0.0064; 0.0067];      %[kg/m^2]
I2 = [0.0149; 0.3564; 0.3553];      %[kg/m^2]
I3 = [0.0025; 0.0551; 0.0546];      %[kg/m^2]
I3_cross = [0; 0.0034; 0];          %[kg/m^2]
I4 = [0.0012; 0.0012; 0.0009];      %[kg/m^2]
I5 = [0.0012; 0.0012; 0.0009];      %[kg/m^2]
I6 = [0.0001; 0.0001; 0.0001];      %[kg/m^2]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Harmonic Drive parameters 

Jin_20=0.404*10^(-4);  %[kg*m^2]
Jin_14=0.091*10^(-4);  %[kg*m^2]

K1_20 = 16000 ;     %[Nm/rad]
K2_20 = 25000 ;     %[Nm/rad]
K3_20 = 29000 ;     %[Nm/rad]
K1_14 = 4700 ;      %[Nm/rad]
K2_14 = 6100 ;      %[Nm/rad]
K3_14 = 7100 ;      %[Nm/rad]
     
Bmw_plus=0.008;     %[Nm]
Bmw_minus=-0.007;   %[Nm]
Bmw=6.4*10^(-4);    %[Nm/(rad/s)]

Bf_plus=0.4;    %[Nm]
Bf_minus=-0.4;  %[Nm]

N=100;     %gear ratio between torques

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% % DESIRED TRAJECTORIES


% INVERSE KINEMATICS

[UR5, importInfo] = importrobot('UR5_plant.slx') ;
showdetails(UR5)

T = 4000;
time_step = 0.001 ;

qi_des = zeros(6,T);
ws_traj = zeros(3,T);

gik = generalizedInverseKinematics('RigidBodyTree',UR5,'ConstraintInputs',{'pose'}) ;
initialGuess = UR5.homeConfiguration;


for t = 1:T
    % We make the robot performe an ellipse
    translation = [0.3+0.2*cos(t*pi/1000), 0.3+0.15*sin(t*pi/1000), 0.65];
    rotation = [0,0,0];
    ws_traj(:,t) = translation;

    desiredPose = trvec2tform(translation)*eul2tform(rotation); 
    poseTg = constraintPoseTarget('Body6');
    poseTg.TargetTransform = desiredPose ;

    [configSol, solutionInfo] = gik(initialGuess, poseTg) ;
    qi_des(:,t) = [configSol.JointPosition] ;
    initialGuess = configSol;
 
end

figure(1);
plot3(ws_traj(1,:),ws_traj(2,:),ws_traj(3,:))
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
title('Workspace desired trajectory')

figure(2);
time = 1:T;
plot(time, qi_des)
xlabel('t')
ylabel('Joint positions [rad]')
legend('q1','q2','q3','q4','q5','q6')


[dqi_des, ddqi_des] = derivatives(qi_des);

figure(3);
time = 1:T;
plot(time,dqi_des)
xlabel('t')
ylabel('Joint velocities [rad/s]')
legend('dq1','dq2','dq3','dq4','dq5','dq6')

figure(4);
plot(time, ddqi_des)
xlabel('t')
ylabel('Joint acceleration [rad/s^2]')
legend('q1','q2','q3','q4','q5','q6')


% figure(5);
% plot3(ws_traj(1,:),ws_traj(2,:),ws_traj(3,:))
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% hold on
% rc = rateControl(10);
% for i = 1:T
%       robotTrajectory = struct('JointName', {}, 'JointPosition', {});
%     for j=1:6
%         joint_name = ['Joint', num2str(j)];
%         joint_position = qi_des(j,i); 
%         robotTrajectory(end+1).JointName = joint_name;
%         robotTrajectory(end).JointPosition = joint_position;
%     end
%     show(UR5, robotTrajectory,FastUpdate=true,PreservePlot=false);
%     title(['Solver status: ' solutionInfo.Status])
%     waitfor(rc);
% 
% end
% hold off


%To simulink
Time_span = 4000 ;
sampleTime = 0.001; 
time_instant = sampleTime*(0:Time_span-1);

time_instant = time_instant';


q1_des = timeseries(qi_des(1,:), time_instant) ;
q2_des = timeseries(qi_des(2,:), time_instant) ;
q3_des = timeseries(qi_des(3,:), time_instant) ;
q4_des = timeseries(qi_des(4,:), time_instant) ;
q5_des = timeseries(qi_des(5,:), time_instant) ;
q6_des = timeseries(qi_des(6,:), time_instant) ;

dq1_des = timeseries(dqi_des(1,:), time_instant) ;
dq2_des = timeseries(dqi_des(2,:), time_instant) ;
dq3_des = timeseries(dqi_des(3,:), time_instant) ;
dq4_des = timeseries(dqi_des(4,:), time_instant) ;
dq5_des = timeseries(dqi_des(5,:), time_instant) ;
dq6_des = timeseries(dqi_des(6,:), time_instant) ;

ddq1_des = timeseries(ddqi_des(1,:), time_instant) ;
ddq2_des = timeseries(ddqi_des(2,:), time_instant) ;
ddq3_des = timeseries(ddqi_des(3,:), time_instant) ;
ddq4_des = timeseries(ddqi_des(4,:), time_instant) ;
ddq5_des = timeseries(ddqi_des(5,:), time_instant) ;
ddq6_des = timeseries(ddqi_des(6,:), time_instant) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % GRAVITY COMPENSATION

gravity1 = out.tg1_ref;
gravity2 = out.tg2_ref;
gravity3 = out.tg3_ref;
gravity4 = out.tg4_ref;
gravity5 = out.tg5_ref;
gravity6 = out.tg6_ref;



g1_ref = interp1(linspace(0, 1, numel(gravity1.Data)),gravity1.Data, linspace(0, 1, T), 'spline');
g2_ref = interp1(linspace(0, 1, numel(gravity2.Data)),gravity2.Data, linspace(0, 1, T), 'spline');
g3_ref = interp1(linspace(0, 1, numel(gravity3.Data)),gravity3.Data, linspace(0, 1, T), 'spline');
g4_ref = interp1(linspace(0, 1, numel(gravity4.Data)),gravity4.Data, linspace(0, 1, T), 'spline');
g5_ref = interp1(linspace(0, 1, numel(gravity5.Data)),gravity5.Data, linspace(0, 1, T), 'spline');
g6_ref = interp1(linspace(0, 1, numel(gravity6.Data)),gravity6.Data, linspace(0, 1, T), 'spline');



% g1_ref = zeros(1,T);
% g2_ref = zeros(1,T);
% g3_ref = zeros(1,T);
% g4_ref = zeros(1,T);
% g5_ref = zeros(1,T);
% g6_ref = zeros(1,T);


figure(8);
plot (time,g1_ref)
hold on
plot (time,g2_ref)
plot (time,g3_ref)
plot (time,g4_ref)
plot (time,g5_ref)
plot (time,g6_ref)
xlabel('t');
ylabel('Nm');
title('Reference torque due to gravity')
legend('tg1','tg2','tg3','tg4','tg5','tg6')
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% % POSITION CONTROL

%INERTIA MATRIX ESTIMATION


J1_est = 3.66;              %[kg*m^2]
J2_est = 4.07;              %[kg*m^2]
J3_est = 2.48;              %[kg*m^2]
J4_est = 0.12;              %[kg*m^2]
J5_est = 0.02;              %[kg*m^2]
J6_est = 5.66*10^(-4);      %[kg*m^2]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WAVE GENERATOR TRAJECTORIES
qw_des = zeros(6,T);


for t=1:T
    qw_des(1,t) = wg_traj(qi_des(1,t),ddqi_des(1,t),g1_ref(t),N,K1_20,J1_est);
    qw_des(2,t) = wg_traj(qi_des(2,t),ddqi_des(2,t),g2_ref(t),N,K1_20,J2_est);
    qw_des(3,t) = wg_traj(qi_des(3,t),ddqi_des(3,t),g3_ref(t),N,K1_20,J3_est);
    qw_des(4,t) = wg_traj(qi_des(4,t),ddqi_des(4,t),g4_ref(t),N,K1_14,J4_est);
    qw_des(5,t) = wg_traj(qi_des(5,t),ddqi_des(5,t),g5_ref(t),N,K1_14,J5_est);
    qw_des(6,t) = wg_traj(qi_des(6,t),ddqi_des(6,t),g6_ref(t),N,K1_14,J6_est);
end

[dqw_des, ddqw_des] = derivatives(qw_des);


figure(6);
subplot (2,1,1)
time = 1:T;
plot(time,qw_des)
xlabel('t')
ylabel('rad')
title('Wave generator position')
legend('qw1','qw2','qw3','qw4','qw5','qw6')
subplot (2,1,2)
plot(time,dqw_des)
xlabel('t')
ylabel('rad/s')
title('Wave generator velocity')
legend('dqw1','dqw2','dqw3','dqw4','dqw5','dqw6')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FEEDFORWARD ACTIONS
uff = zeros(6,T);
for t=1:T
    uff(1,t) = ff_action(qw_des(1,t),dqw_des(1,t),ddqw_des(1,t),qi_des(1,t),K1_20,N,Bmw,Jin_20);
    uff(2,t) = ff_action(qw_des(2,t),dqw_des(2,t),ddqw_des(2,t),qi_des(2,t),K1_20,N,Bmw,Jin_20);
    uff(3,t) = ff_action(qw_des(3,t),dqw_des(3,t),ddqw_des(3,t),qi_des(3,t),K1_20,N,Bmw,Jin_20);
    uff(4,t) = ff_action(qw_des(4,t),dqw_des(4,t),ddqw_des(4,t),qi_des(4,t),K1_14,N,Bmw,Jin_14);
    uff(5,t) = ff_action(qw_des(5,t),dqw_des(5,t),ddqw_des(5,t),qi_des(5,t),K1_14,N,Bmw,Jin_14);
    uff(6,t) = ff_action(qw_des(6,t),dqw_des(6,t),ddqw_des(6,t),qi_des(6,t),K1_14,N,Bmw,Jin_14);
end

figure(7);
time = 1:T;
plot(time,uff)
xlabel('t')
ylabel('FF actions')
legend('uff1','uff2','uff3','uff4','uff5','uff6')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FEEDBACK ACTION
%weights associated with the control inputs
wR1 = 5;
wR2 = 5;
wR3 = 5;
wR4 = 0.1;
wR5 = 0.1;
wR6 = 0.1;

% Proportional controller
K_fb_1 = fb_action(K1_20,N,Jin_20,Bmw,J1_est,wR1);
K_fb_2 = fb_action(K1_20,N,Jin_20,Bmw,J2_est,wR2);
K_fb_3 = fb_action(K1_20,N,Jin_20,Bmw,J3_est,wR3);
K_fb_4 = fb_action(K1_14,N,Jin_14,Bmw,J4_est,wR4);
K_fb_5 = fb_action(K1_14,N,Jin_14,Bmw,J5_est,wR5);
K_fb_6 = fb_action(K1_14,N,Jin_14,Bmw,J6_est,wR6);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% % SEND DATA SIGNALS TO SIMULINK

Time_span = 4000 ;
sampleTime = 0.001; 
time_instant = sampleTime*(0:Time_span-1);

time_instant = time_instant';



qw1_des = timeseries(qw_des(1,:), time_instant) ;
qw2_des = timeseries(qw_des(2,:), time_instant) ;
qw3_des = timeseries(qw_des(3,:), time_instant) ;
qw4_des = timeseries(qw_des(4,:), time_instant) ;
qw5_des = timeseries(qw_des(5,:), time_instant) ;
qw6_des = timeseries(qw_des(6,:), time_instant) ;

dqw1_des = timeseries(dqw_des(1,:), time_instant) ;
dqw2_des = timeseries(dqw_des(2,:), time_instant) ;
dqw3_des = timeseries(dqw_des(3,:), time_instant) ;
dqw4_des = timeseries(dqw_des(4,:), time_instant) ;
dqw5_des = timeseries(dqw_des(5,:), time_instant) ;
dqw6_des = timeseries(dqw_des(6,:), time_instant) ;


uff_1 = timeseries(uff(1,:), time_instant) ;
uff_2 = timeseries(uff(2,:), time_instant) ;
uff_3 = timeseries(uff(3,:), time_instant) ;
uff_4 = timeseries(uff(4,:), time_instant) ;
uff_5 = timeseries(uff(5,:), time_instant) ;
uff_6 = timeseries(uff(6,:), time_instant) ; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ERROR IN THE WORKSPACE
theta1 = out.q1;
theta2 = out.q2;
theta3 = out.q3;
theta4 = out.q4;
theta5 = out.q5;
theta6 = out.q6;

% Utilizzo della funzione resample per la conversione

q1 = interp1(linspace(0, 1, numel(theta1.Data)),theta1.Data, linspace(0, 1, T), 'spline');
q2 = interp1(linspace(0, 1, numel(theta2.Data)),theta2.Data, linspace(0, 1, T), 'spline');
q3 = interp1(linspace(0, 1, numel(theta3.Data)),theta3.Data, linspace(0, 1, T), 'spline');
q4 = interp1(linspace(0, 1, numel(theta4.Data)),theta4.Data, linspace(0, 1, T), 'spline');
q5 = interp1(linspace(0, 1, numel(theta5.Data)),theta5.Data, linspace(0, 1, T), 'spline');
q6 = interp1(linspace(0, 1, numel(theta6.Data)),theta6.Data, linspace(0, 1, T), 'spline');


% Calcolo della traiettoria dell'end effector
endEffectorTrajectory = zeros(3,T);
config=UR5.homeConfiguration;
for t = 1:T
    % Calcolo degli angoli delle giunture per il punto corrente
   config(1).JointPosition = q1(t);
   config(2).JointPosition = q2(t);
   config(3).JointPosition = q3(t);
   config(4).JointPosition = q4(t);
   config(5).JointPosition = q5(t);
   config(6).JointPosition = q6(t);
   % Calcolo della cinematica diretta (posizione e orientamento dell'end effector)
   endEffectorTransform = getTransform(UR5, config, 'Body6', 'Base');
    
    
   % Estrazione della posizione dell'end effector dalla trasformazione
   endEffectorPosition_x = endEffectorTransform(1,4) ;
   endEffectorPosition_y = endEffectorTransform(2,4) ;
   endEffectorPosition_z = endEffectorTransform(3,4) ;
   endEffectorTrajectory(1,t) = endEffectorPosition_x;
   endEffectorTrajectory(2,t) = endEffectorPosition_y;
   endEffectorTrajectory(3,t) = endEffectorPosition_z;


   % Salvataggio della posizione dell'end effector nella traiettoria
 
end



error_w = zeros(3,T);
for t=1:T
    error_w(1,t) = endEffectorTrajectory(1,t)-ws_traj(1,t);
    error_w(2,t) = endEffectorTrajectory(2,t)-ws_traj(2,t);
    error_w(3,t) = endEffectorTrajectory(3,t)-ws_traj(3,t);
end

figure(9)
plot(time,error_w(1,:))
hold on
grid on
plot(time,error_w(2,:))
plot(time,error_w(3,:))
legend('error_x','error_y','error_z')
title('Error in the workspace')
hold off

figure(10)
plot3(endEffectorTrajectory(1,:),endEffectorTrajectory(2,:),endEffectorTrajectory(3,:))
hold on
grid on
plot3(ws_traj(1,:),ws_traj(2,:),ws_traj(3,:))
xlabel('X');
ylabel('Y');
zlabel('Z');
legend('real','reference')
title('Workspace')
hold off





