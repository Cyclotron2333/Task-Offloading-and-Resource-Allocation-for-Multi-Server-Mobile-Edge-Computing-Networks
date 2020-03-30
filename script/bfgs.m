function bfgs
%拟牛顿法求最值
N=100;
x0=zeros(N,1);
eps=1e-4;
g0=G(x0, N);
step=0;
H=eye(N, N);
while norm(g0)>=eps 
    fprintf('step %d: %.10f\t %f\n',step, F(x0, N), norm(g0));
    s0=-H*g0;
    %linear search
    lambda0=1;
    c1=0.1; c2=0.5;
    a=0; b= inf;
    temp=g0'* s0;
    while 1
        x1=x0+lambda0*s0;
        if F(x0, N)-F(x1, N) < -c1*lambda0*temp
            b=lambda0;
            lambda=(lambda0+a)/2;
        elseif G(x1, N)'*s0 < c2*temp
            a=lambda0;
            lambda=min(2*lambda0, (lambda0+b)/2);
        else
            break;
        end
        if abs(lambda-lambda0)<=eps
            break;
        else
            lambda0=lambda;
        end
        %fprintf('%f\n',lambda0);
    end
    
    x1=x0+lambda0*s0;
    g1=G(x1, N);
    delta_x=x1-x0;
    delta_g=g1-g0;
    miu=1+((delta_g')*H*delta_g)/((delta_x')*delta_g);
    % 更新H
    H=H+((miu*delta_x*(delta_x')-H*delta_g*(delta_x')-delta_x*(delta_g')*H))/((delta_x')*delta_g);
    x0=x1;
    g0=g1;
    step=step+1;
end
fprintf('--------BFGS (total step %d)---------\nx*=',step)
for i=1:N
    fprintf('%.2f ',x0(i));
end
fprintf('\nf(x*)=%.2f\n',F(x0, N));
end
