function [J, X, P, F] = optimize(Fu,Fs,Tu,G,B,W,Pur,Pu,Ht,Hr,lamda,beta_time,beta_enengy,userNumber,serverNumber,sub_bandNumber)
%optimize 负责执行优化操作
    tu_local = Tu.circle./Fu;   %本地计算时间矩阵
    k = rand;
    Eu_local = k * (Fu.*Fu) * Tu.circle;    %本地计算能耗矩阵
    Eta_user = zero(userNumber,1);
    for i=1:userNumber  %计算CRA所需的η
        Eta_user(i) = lamda * Tu(i).circle * lamda(i) / tu_local(i);
    end
    
   [J, X, P, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    T,...                       % 初始化温度值
    T_min,...                   % 温度下界
    alpha,...                   % 温度的下降率
    k, ...                      % 邻域解空间的大小
    minimal_cost,...            % 最小目标值（函数值越小，则适应度越高）
    para...                     % 所需参数
    );
end