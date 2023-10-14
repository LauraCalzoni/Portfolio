function [K_fb] = fb_action(K,N,Jmw,Bmw,Ji,wR)
%FB_ACTION computes the gain for the feedback control action in order to
%stabilize the HD-joint subsystem

    %state space model
    A = zeros(4,4); %state matrix
    B = zeros(4,1); %state-input matrix
    
    A(1,2) = 1;
    A(2,1) = -K/(Jmw*(N^2));
    A(2,2) = -Bmw/Jmw;
    A(2,3) = K/(Jmw*N);
    A(3,4) = 1;
    A(4,1) = K/(N*Ji);
    A(4,3) = -K/Ji;
    
    
    B(2,1) = 1/Jmw;
    
        
    % LQR 
    wQ1 = 1;
    wQ2 = 0.1;
    wQ3 = 10;
    wQ4 = 0.1;

    Q = diag([wQ1 wQ2 wQ3 wQ4]);
    R = wR*ones(1,1);
    

    [K_fb, S, P] = lqr(A, B, Q, R);

end

