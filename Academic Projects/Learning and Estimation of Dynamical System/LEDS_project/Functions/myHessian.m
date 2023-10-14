% Hessian of the loss function

function J_hess= myHessian(Phi,Theta)
    z=Phi*Theta;
    F=myLogisticSigmoid(z);
    N=length(z);
    W=eye(N);
    for i=1:N
        W(i,i)=F(i)*(1-F(i));
    end
    J_hess=(Phi')*W*Phi;
end

