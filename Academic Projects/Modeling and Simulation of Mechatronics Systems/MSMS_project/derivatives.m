function [dq,ddq] = derivatives(q)
%DERIVATIVES computes the velocity and acceleration profiles given a
%position trajectory
    
    T=size(q,2);
    
    dq = zeros(6, T);
    ddq = zeros(6, T);
    
    dt = 0.001;
    
    for j = 1:6
        dq(j,2:T) = diff(q(j,:))/dt;
        dq(j,1) = dq(j,2);
        ddq(j,2:T) = diff(dq(j,:))/dt;
        ddq(j,1) = ddq(j,2);
    end

end

