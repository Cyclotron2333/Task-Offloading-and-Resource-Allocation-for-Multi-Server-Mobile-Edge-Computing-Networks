function tests = optimizeTest
    tests = functiontests(localfunctions);
end
 
%% testTa
function testOptimize(~)
    userNumber = 50;
    serverNumber = 10;
    sub_bandNumber = 5;
    Fs = 20e9 * ones(serverNumber,1);   %服务器运算能力矩阵
    Fu = 1e9 * ones(userNumber,1);  %用户运算能力矩阵
    T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
    T0.circle = [];
    Tu = repmat(T0,userNumber);
    for i = 1:userNumber    %初始化任务矩阵
        Tu(i).data = 420 * 1024 * 8;
        Tu(i).circle = 50e6;
    end
    lamda = ones(userNumber,1);
    beta_time = 0.2 * ones(userNumber,1);
    beta_enengy = ones(userNumber,1) - beta_time;
    H = 140.7 * ones(userNumber,serverNumber,sub_bandNumber) + 36.7*log10(0.112*rand(userNumber,serverNumber,sub_bandNumber));   %用户到服务器的增益矩阵
    Pu = 0.001 * 10^2 * ones(userNumber,1);    %用户输出功率矩阵
    
    Sigma_square = 0.001 * 10^(-100/10);
    W = 20e6;   %系统总带宽
    k = 5e-27;
    
    [J, X, F] = optimize(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                           % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber,...
    2000,...                        % 初始化温度值
    1e-8,...                        % 温度下界
    0.95,...                        % 温度的下降率
    10, ...                         % 邻域解空间的大小
    300 ...                         % 最小目标值（函数值越小，则适应度越高）
    );

    J
    X
    F
end