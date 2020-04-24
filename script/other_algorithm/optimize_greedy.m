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
