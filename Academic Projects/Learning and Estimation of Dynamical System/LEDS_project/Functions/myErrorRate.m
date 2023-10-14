% Error rate function

function Er = myErrorRate(y_hat,y)
    N=length(y);
    error=0;
    for i=1:N
        if y_hat(i)~= y(i)
            error=error+1;
        end
    end
    Er=error/N;
end

