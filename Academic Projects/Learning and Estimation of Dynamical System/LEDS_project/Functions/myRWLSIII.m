function [theta] = myRWLSIII(y,n,lambda,theta_0,initial_point)
    % Inizialization
    L = length(y)-n;
    theta_k = theta_0;
    S_inv = eye(n);
        
    % RWLS_III
    for t = initial_point:L
        phi = -flipud(y(t:t+n-1));
        S_inv = (1/lambda)*S_inv-((S_inv*phi*(phi')*S_inv)/(lambda*(lambda+(phi')*S_inv*phi)));
        theta_k = theta_k + (S_inv*phi)*(y(t+n)-((phi')*theta_k));
    end
    
    theta=theta_k;
end

