function [P,Q] = pra(G,beta_time,beta_enengy,Tu,tu_local,Eu_local,lamda,W,Ht,Pu,Sigma,r,Epsilon,beta)
%uplink power resourses allocation 上行链路功率资源分配
    [userNumber,serverNumber,~] = size(G);
    P = sym('p',[1 userNumber]);   %用户发射功率分配矩阵
    syms f;
    for server = 1:serverNumber
       [Us,n] = genUs(G,server);
        if n > 0
            for user = 1:n
                Pi = getPi(G,Pu,Sigma,Ht,user,server);
                Phi_user = beta_time(Us(user)) * Tu(Us(user)).data * lamda(Us(user)) / tu_local(Us(user)) / W;
                Theta_user = beta_enengy(Us(user)) * Tu(Us(user)).data * lamda(Us(user)) / Eu_local(Us(user)) / W;
                if server == 1 && user== 1
                    f = ( Phi_user + Theta_user * P(Us(user)) ) / log2( 1 + P(Us(user)) * Pi );
                else
                    f = f + ( Phi_user + Theta_user * P(Us(user)) ) / log2( 1 + P(Us(user)) * Pi );
                end
                f = f - r * ( log(P(Us(user))) + log( Pu(Us(user)) - P(Us(user)) ) );
            end
        end
    end
    
end

