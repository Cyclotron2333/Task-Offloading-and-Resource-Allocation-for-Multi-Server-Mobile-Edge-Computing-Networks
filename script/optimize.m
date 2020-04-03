function [J, X, P, F] = optimize(Fu,Fs,Tu,W,Pur,Pu,Ps,Ht,Hr,...
    lamda,Sigma,Epsilon,beta,r,beta_time,beta_enengy,...
    k,...                       % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber,...
    T,...                       % 初始化温度值
    T_min,...                   % 温度下界
    alpha,...                   % 温度的下降率
    n, ...                      % 邻域解空间的大小
    minimal_cost...             % 最小目标值（函数值越小，则适应度越高）
    )

%optimize 负责执行优化操作
    tu_local = zeros(userNumber,1);
    Eu_local = zeros(userNumber,1);
    for i = 1:userNumber    %初始化任务矩阵
        Tu(i).data = 10 + 40 * rand;
        Tu(i).circle = 40 * rand;
        Tu(i).output = 4 * rand;
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
    para.Hr = Hr;
    para.Ht = Ht;
    para.Pur = Pur;
    para.Ps = Ps;
    para.lamda = lamda;
    para.Pu = Pu;
    para.Sigma = Sigma;
    para.r = r;
    para.Epsilon = Epsilon;
    para.beta = beta;
    para.Fs = Fs;
    para.Eta_user = Eta_user;
    
   [J, X, P, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    T,...                       % 初始化温度值
    T_min,...                   % 温度下界
    alpha,...                   % 温度的下降率
    n, ...                      % 邻域解空间的大小
    minimal_cost,...            % 最小目标值（函数值越小，则适应度越高）
    para...                     % 所需参数
    );

end