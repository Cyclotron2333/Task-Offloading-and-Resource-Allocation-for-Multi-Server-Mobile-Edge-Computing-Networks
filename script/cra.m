function [F,T] = cra(G,Fs,Eta_user)
%CRA computer resourses allocation 运算能力分配
    [userNumber,serverNumber,~] = size(G);
    F = zeros(userNumber,serverNumber);
    T = 0;
    for server = 1:serverNumber
        [Us,n] = genUs(G,server);
        if n > 0 
            EtaRoot_sum = sum(Eta_user(Us(:,1)).^(0.5));
            F(Us(:,1),server) = Fs(server) * Eta_user(Us(:,1)).^(0.5) / EtaRoot_sum;
            T = T + 1/Fs(server) * EtaRoot_sum^2;
        end
    end
end