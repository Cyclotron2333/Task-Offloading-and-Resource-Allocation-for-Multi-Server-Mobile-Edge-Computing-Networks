function [F,T] = cra(G,Fs,Eta_user)
%CRA computer resourses allocation 运算能力分配
    [userNumber,serverNumber,~] = size(G);
    F = zeros(userNumber,serverNumber);
    T = 0;
    for server = 1:serverNumber
        [Us,n] = genUs(G,server);
        EtaRoot_sum = 0;
        for user = 1:n
            EtaRoot_sum = EtaRoot_sum + Eta_user(Us(user,1))^(0.5);
        end
        if n > 0
            for user = 1:n
                F(Us(user,1),server) = Fs(server) * Eta_user(Us(user,1))^(0.5) / EtaRoot_sum;
            end
            T = T + 1/Fs(server) * EtaRoot_sum^2;
        end
    end
end