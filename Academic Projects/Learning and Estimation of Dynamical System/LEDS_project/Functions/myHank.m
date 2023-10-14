% Hankel matrix generator
%Input:
%       - s:  data vector
%       - n:  model order

function H = myHank(s,n)
    N=length(s);

    H=zeros(N-n,n);

    for j=n:-1:1
        x=n-j+1;
        for i=N-n:-1:1
            H(i,j)=s(x);
            x=x+1;
        end
    end
end
