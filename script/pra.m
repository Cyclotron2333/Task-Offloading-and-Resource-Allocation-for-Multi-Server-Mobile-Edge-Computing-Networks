function [P,Q] = pra(G,beta_time,beta_enengy,Tu,tu_local,Eu_local,W,Ht,Pu,Sigma,r,Epsilon,beta)
%PRA uplink power resourses allocation 上行链路功率资源分配
    [userNumber,serverNumber,~] = size(G);
    P = sym('p',[1 userNumber]);   %用户发射功率分配矩阵
    for server = 1:serverNumber
       [Us,n] = genUs(G,server);
        if n > 0
            for user = 1:n
                Pi = getPi(G,Pu,Sigma,Ht,user,server);
                Phi_user = beta_time(Us(user)) * Tu(Us(user)).data  / tu_local(Us(user)) / W;
                Theta_user = beta_enengy(Us(user)) * Tu(Us(user)).data  / Eu_local(Us(user)) / W;
                if server == 1 && user== 1
                    f = ( Phi_user + Theta_user * P(Us(user)) ) / log2( 1 + P(Us(user)) * Pi );
                else
                    f = f + ( Phi_user + Theta_user * P(Us(user)) ) / log2( 1 + P(Us(user)) * Pi );
                end
                if server == 1 && user== 1
                    g = r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
                else
                    g = g + r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
                end
                f = f - r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
            end
        end
    end
    %F = convertToAcceptArray(matlabFunction(f));
    x0 = ones(1,userNumber);
    g = gradient(f);
    %G = convertToAcceptArray(matlabFunction(g));
    while subs(f,P,X0) < Epsilon
        [x1,res,~] = newtons(f,g,x0,100);
        x0 = x1;
        r = beta * r;
    end
    Q = res;
    P = x0;
end

function f = convertToAcceptArray(old_f)
%将函数句柄转化为能接收矩阵的类型
    function r = new_f(X)
        X = num2cell(X);
        r = old_f(X{:});
    end
    f = @new_f;
end

function Pi = getPi(G,Pu,Sigma,Ht,user,server)
%GetPi 计算Pi_us
    Pi = 0;
    [~,serverNumber,sub_bandNumber] = size(G);
    for j = 1:sub_bandNumber
        denominator = 0;
        for i = 1:serverNumber
            if i ~= server
                [Us,n] = genUs(G,i);
                for k = 1:n
                    denominator = denominator + G(Us(k),i,j) * Pu(Us(k)) * Ht(Us(k),i,j);
                end
            end
        end
        denominator = denominator + Sigma^2;
        Pi = Ht(user,server,j)/denominator;
    end
end
