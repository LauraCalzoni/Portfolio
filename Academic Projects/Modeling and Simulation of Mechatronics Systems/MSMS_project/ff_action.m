
function [uff] = ff_action(qw_des,dqw_des,ddqw_des,qi_des,K,N,Bmw,Jmw)
%FF_ACTION implementation of the feedforward term for each joint

    uff = (K/(N^2))*qw_des + Bmw*dqw_des - (K/N)*qi_des + Jmw*ddqw_des;

end
  

