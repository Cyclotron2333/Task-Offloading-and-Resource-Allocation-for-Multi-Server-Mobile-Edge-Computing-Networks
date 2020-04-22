function [J, X, F] = optimize_greedy(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                       % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber ...
    )

%optimize 负责执行优化操作
    tu_local = zeros(userNumber,1);
    Eu_local = zeros(userNumber,1);
    for i = 1:userNumber    %初始化任务矩阵
        tu_local(i) = Tu(i).circle/Fu(i);   %本地计算时间矩阵
        Eu_local(i) = k * (Fu(i))^2 * Tu(i).circle;    %本地计算能耗矩阵
    end
    Eta_user = zeros(userNumber,1);
    for i=1:userNumber  %计算CRA所需的η
        Eta_user(i) = beta_time(i) * Tu(i).circle * lamda(i) / tu_local(i);
    end
    
    %封装参数
    para.beta_time = beta_time;
    para.beta_enengy = beta_enengy;
    para.Tu = Tu;
    para.tu_local = tu_local;
    para.Eu_local = Eu_local;
    para.W = W;
    para.Ht = H;
    para.lamda = lamda;
    para.Pu = Pu;
    para.Sigma_square = Sigma_square;
    para.Fs = Fs;
    para.Eta_user = Eta_user;
    
   [J, X, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    para ...                    % 所需参数
    );

end

function [J, X, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    para ...                    % 所需参数
)
%TA Task allocation,任务分配算法，采用模拟退火算法

    X = zeros(userNumber, serverNumber,sub_bandNumber);
    
    for user = 1:userNumber
       [~,server,~] = ind2sub(size(X),find(para.Ht == max(para.Ht(user,:,1))));
       if ~isempty(server)
            sub_band = find(~any(X(:,server(1),:)));
            if ~isempty(sub_band)
                X(user,server(1),sub_band(1)) = 1;
            else
                sub_band = randi(sub_bandNumber);
                X(user,server(1),sub_band) = 1;
            end
       end
    end
    [J, F] = Fx(X,para);
end
 


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
%GetPi 计算Pi_us
    B = W / sub_bandNumber;
    Pi = beta_time(user)/tu_local(user) + beta_enengy(user)/Eu_local(user)*Pu(user);
    Gamma_us = getGamma(x,Pu,Sigma_square,Ht,user,server,band);
    Pi = Pi * Tu(user).data / B / log2(1 + Gamma_us) * multiplexingNumber;
end

function Gamma = getGamma(G,Pu,Sigma_square,H,user,server,band)
%GetGamma 计算Gamma_us
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

