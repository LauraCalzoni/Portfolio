function [theta]=myLSbatch(y,n,N)

    % N = initial number of samples I collect to perform the initial batch estimate

    Hy = myHank(-y,n); 
    Y=y(end:-1:(n+1));

    theta=((transpose(Hy)*Hy).*(1/N))\((transpose(Hy)*Y).*(1/N));

end