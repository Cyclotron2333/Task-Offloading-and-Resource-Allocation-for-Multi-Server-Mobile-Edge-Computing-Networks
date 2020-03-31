function [F,T] = cra(G,Fs,Eta_user)
%computer resourses allocation 运算能力分配
    [userNumber,serverNumber,~] = size(G);
    Eta_sum = sum(Eta_user);
    F = zeros(userNumber,serverNumber);
    T = 0;
    for i = 1:serverNumber
        [Us,n] = genUs(G,i);
        if n > 0
            tempSum = 0;
            for j = 1:n
                F(Us(i)) = fs * Eta_user(i)^(0.5) / Eta_sum;
                tempSum = tempSum + Eta_user(i)^(0.5);
            end
            T = T + 1/Fs(i) * tempSum^2;
        end
    end
end