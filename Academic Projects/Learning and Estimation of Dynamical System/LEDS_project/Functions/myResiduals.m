%   This function compute the residuals of the model as well as the matrix
%   W (used to compute the weighted loss function) and it's useful in the
%   computation of J

%   Input:
%       - y:      output data
%       - theta:  parameter estimated
%       - n:      model order
%       -lambda:  forgetting factor
%   Output:
%       - epsilon:  residuals
%       - W:        diagonal matrix with the powers of the forgetting factor

function [epsilon,W] = myResiduals(y,theta,n,lambda)

    % Inizialization
    N=length(y)-n;
    W=zeros(N,N);
    epsilon = zeros(N,1);
    
    for i = 1:N
        W(i,i)=lambda^(N-i);
        phi_ = flip(-y(i:i+n-1));
        epsilon(i) = y(i+n) - phi_'*theta;
    end
end