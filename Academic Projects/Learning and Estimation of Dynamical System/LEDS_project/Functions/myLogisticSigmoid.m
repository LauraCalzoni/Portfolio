% Implementation of the logistic sigmoid function

function F = myLogisticSigmoid(z)
    N=length(z);
    F=zeros(N,1);
    for i=1:N
        F(i)=exp(z(i))/(1+exp(z(i)));
    end
end

