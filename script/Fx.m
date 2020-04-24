function [Jx, F] = Fx(x,para)
    [F,res_cra] = cra(x,para.Fs,para.Eta_user);
    Jx = 0;
    [~,serverNumber,sub_bandNumber] = size(x);
    for server = 1:serverNumber
        [Us,n] = genUs(x,server);
        multiplexingNumber = zeros(sub_bandNumber,1);
        for band = 1:sub_bandNumber
            multiplexingNumber(band) = sum(x(:,server,band));
        end
        if n > 0
            for user = 1:n
                Pi = getPi(x,Us(user,1),server,Us(user,2),sub_bandNumber,multiplexingNumber(Us(user,2)),para.beta_time,para.beta_enengy,para.tu_local,para.Eu_local,para.Tu,para.Pu,para.Ht,para.Sigma_square,para.W);
                Jx = Jx + para.lamda(Us(user,1)) * (1 - Pi);
            end
        end
    end
    Jx = (Jx - res_cra);
end

function Pi = getPi(x,user,server,band,sub_bandNumber,multiplexingNumber,beta_time,beta_enengy,tu_local,Eu_local,Tu,Pu,Ht,Sigma_square,W)
%GetPi º∆À„Pi_us
    B = W / sub_bandNumber;
    Pi = beta_time(user)/tu_local(user) + beta_enengy(user)/Eu_local(user)*Pu(user);
    Gamma_us = getGamma(x,Pu,Sigma_square,Ht,user,server,band);
    Pi = Pi * Tu(user).data / B / log2(1 + Gamma_us) * multiplexingNumber;
end

function Gamma = getGamma(G,Pu,Sigma_square,H,user,server,band)
%GetGamma º∆À„Gamma_us
    [~,serverNumber,~] = size(G);
    denominator = 0;
    for i = 1:serverNumber
        if i ~= server
            [Us,n] = genUs(G,i);
            for k = 1:n
                denominator = denominator + G(Us(k,1),i,band) * Pu(Us(k,1)) * H(Us(k,1),server,band);
            end
        end
    end
    denominator = denominator + Sigma_square;
    Gamma = Pu(user)*H(user,server,band)/denominator;
end