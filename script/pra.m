function [P,Q] = pra(G,beta_time,beta_enengy,Tu,tu_local,Eu_local,W,Ht,Pu,Sigma,r,Epsilon,beta,lamda)
%PRA uplink power resourses allocation 上行链路功率资源分配
    [userNumber,serverNumber,~] = size(G);
    P = sym('p',[1 userNumber]);   %用户发射功率分配矩阵
    flag_first = 1;
    for server = 1:serverNumber
       [Us,n] = genUs(G,server);
        if n > 0
            for user = 1:n
                Pi = getPi(G,Pu,Sigma,Ht,user,server);
                Phi_user = lamda(Us(user)) * beta_time(Us(user)) * Tu(Us(user)).data  / tu_local(Us(user)) / W;
                Theta_user = lamda(Us(user)) * beta_enengy(Us(user)) * Tu(Us(user)).data  / Eu_local(Us(user)) / W;
                if flag_first == 1
                    f = ( Phi_user + Theta_user * P(Us(user)) ) / log2( 1 + P(Us(user)) * Pi );
                    t = r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
                    flag_first = 0;
                else
                    f = f + ( Phi_user + Theta_user * P(Us(user)) ) / log2( 1 + P(Us(user)) * Pi );
                    t = t + r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
                end
                f = f - r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
            end
        end
    end
    %F = convertToAcceptArray(matlabFunction(f));
    x0 = rand(1,userNumber);
    if exist('f') == 0
        Q = 0;
        P = x0;
        return;
    else
        l(P) = f;   %指定自变量再求梯度
    end
    g = gradient(l);
    %G = convertToAcceptArray(matlabFunction(g));
    while 1
        [x1,res,~,~] = newtons(f,g,P,x0);
        x0 = x1;
        if r * abs(double(subs(t,P,x0))) <= Epsilon
            break;
        end
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
    for sub_band = 1:sub_bandNumber
        denominator = 0;
        for i = 1:serverNumber
            if i ~= server
                [Us,n] = genUs(G,i);
                for k = 1:n
                    denominator = denominator + G(Us(k),i,sub_band) * Pu(Us(k)) * Ht(Us(k),i,sub_band);
                end
            end
        end
        denominator = denominator + Sigma^2;
        Pi = Ht(user,server,sub_band)/denominator;
    end
end
