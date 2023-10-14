%Gradient of the loss function

function J_grad = myGradient(Phi,Theta,Y)
    z=Phi*Theta;
    F_theta=myLogisticSigmoid(z);
    J_grad=(Phi')*(F_theta-Y);
end

