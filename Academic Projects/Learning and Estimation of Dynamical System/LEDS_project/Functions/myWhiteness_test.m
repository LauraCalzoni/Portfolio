
function [tfw]=myWhiteness_test(autocor,var, N, m, alpha)
    %Whiteness test (chi-square distribution test)
    gamma=1-alpha;
    x=N*((autocor')*var^(-1)*autocor);  % Test quantity
    fprintf('The test quantity is equal to: %d \n', x);  

    Xmalpha=chi2inv(gamma,m);
    fprintf("The Chi-Square level's value : %d\n", Xmalpha);
    
    if x<=Xmalpha
        tfw=('The residual is a zero mean white process, so the model is valid');
    else
        tfw=('The test failed, the model is not valid');
    end
    
 
