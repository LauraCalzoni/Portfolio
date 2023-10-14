function [theta] = myRWLSIV(y,n,alpha,lambda,theta_0,initial_point)
    % Inizialization
    L = length(y)-n;
    theta_k = theta_0;
    R_inv = (1/alpha)*eye(n);
        
    % RWLS_IV
    for t = initial_point:L
        phi = -flipud(y(t:t+n-1));
        R_inv = (1/lambda)*(R_inv-(R_inv*phi*((phi')*R_inv*phi+lambda)^(-1)*(phi')*R_inv));
        theta_k = theta_k + (R_inv*phi)*(y(t+n)-((phi')*theta_k));
    end
    
    theta=theta_k;
end