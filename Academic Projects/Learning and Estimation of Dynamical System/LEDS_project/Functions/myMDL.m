function [mdl,minmdl,p] = myMDL(nmax,y)
    % Inizialization
    mdl = zeros(nmax,1);
    J = zeros(nmax,1);
    N = length(y);
    N_half = round(N/2);  % The first half of the samples is considered to be the training set
    lambda = 0.999;
    alpha = 2;   

    for p = 1:nmax                                              
        theta_in=myLSbatch(y(1:(p*10)),p,p*10);                          % Compute the initial batch estimate                     
        theta=myRWLSIV(y((p*10):N_half),p,alpha,lambda,theta_in,p*10);   % Compute the recursive LS estimation
        %theta=myRWLSIII(y((p*10):N_half),p,lambda,theta_in,p*10);   
        [res,W] = myResiduals(y(1:N_half), theta,p,lambda);              % Compute the residuals
        J(p) = (1/N_half)*(res')*W*res;                                  % Compute the loss function
        mdl(p)=N_half*log(J(p))+2*p*log(N_half);                         % Compute the MDL function
    end

    [minmdl, p] = min(mdl);

    % Plot of the results
    % Plot J
    fprintf('The weighted loss function results to be the following:')
    figure()
    ylabel('J(theta)');
    xlabel('p');
    plot(J,'-o')
    grid on
    title('Loss function with the training set')

    % Plot MDL
    fprintf('The model order suggested by the MDL criterion is equal to %d', p)
    figure()
    ylabel('MDL value');
    xlabel('p');
    plot(mdl,'-o')
    hold on
    grid on
    plot(p, minmdl, 'o')
    title('Minimum Description Lenght')

end